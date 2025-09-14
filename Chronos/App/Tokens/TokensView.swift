import Factory
import SwiftData
import SwiftUI

struct TokenPair: Identifiable {
    var id: ObjectIdentifier
    var token: Token
    var encToken: EncryptedToken
}

enum TokenSortOrder: String {
    case ISSUER_ASC
    case ISSUER_DESC
    case ACCOUNT_ASC
    case ACCOUNT_DESC
}

let sortOptions: [(title: String, criteria: TokenSortOrder)] = [
    ("Issuer (A - Z)", .ISSUER_ASC),
    ("Issuer (Z - A)", .ISSUER_DESC),
    ("Account (A - Z)", .ACCOUNT_ASC),
    ("Account (Z - A)", .ACCOUNT_DESC),
]

struct TokensView: View {
    @Query private var vaults: [Vault]
    @EnvironmentObject var loginStatus: LoginStatus
    @Environment(\.colorScheme) var colorScheme

    @State private var showSettingsSheet = false
    @State private var showTokenAddSheet = false
    @State private var showTagsManagementSheet = false
    @State private var detentHeight: CGFloat = 0
    @State private var sortCriteria: TokenSortOrder = .ISSUER_ASC
    @State private var searchQuery = ""

    @State private var currentTag = "All"

    @State private var tokenPairs: [TokenPair] = []
    @State private var debounceTimer: Timer?
    @State private var isSearchablePresented: Bool = false
    @State private var tagsButtonHeight: CGFloat = 32

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    private var encryptedTokens: [EncryptedToken] {
        if !loginStatus.loggedIn {
            return []
        }

        guard let vaultId = stateService.getVaultId(),
              let vault = vaults.first(where: { $0.vaultId == vaultId })
        else {
            return []
        }

        return vault.encryptedTokens ?? []
    }

    var body: some View {
        NavigationStack {
            List {
                TagsScrollBar()
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

                ForEach(tokenPairs) { tokenPair in
                    TokenRowView(tokenPair: tokenPair, timer: timer, triggerSortAndFilterTokenPairs: self.sortAndFilterTokenPairs)
                }
            }
            .onAppear {
                Task { await updateTokenPairs() }
            }
            .onChange(of: encryptedTokens) { _, _ in
                Task { await updateTokenPairs() }
            }
            .onChange(of: sortCriteria) { _, _ in
                sortAndFilterTokenPairs()
            }
            .onChange(of: searchQuery) { _, _ in
                debounceTimer?.invalidate()
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    Task { await updateTokenPairs() }
                }
            }
            .onChange(of: currentTag) { _, _ in
                Task { await updateTokenPairs() }
            }
            .listStyle(.plain)
            .navigationTitle("Tokens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarContent()
            }
            .overlay {
                EmptyStateView()
            }
            .sheet(isPresented: $showTokenAddSheet) {
                NavigationStack {
                    AddTokenView()
                }
            }
            .navigationDestination(isPresented: $showTagsManagementSheet) {
                TagManagementView()
            }
            .navigationDestination(isPresented: $showSettingsSheet) {
                SettingsView()
            }
            .searchable(text: $searchQuery,
                        isPresented: $isSearchablePresented,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: Text(currentTag == "All" ? "Search tokens" : "Search \"\(currentTag)\" tokens"))
        }
    }

    private func TagsScrollBar() -> some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        TagButton(
                            title: "All",
                            isSelected: currentTag == "All",
                            action: { currentTag = "All" }
                        )
                        .id("All")
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            tagsButtonHeight = height
                        }

                        ForEach(sortedTags, id: \.self) { tag in
                            TagButton(
                                title: tag,
                                isSelected: currentTag == tag,
                                action: { currentTag = tag }
                            )
                            .id(tag)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: tagsButtonHeight)
                }
                .padding(.top, 2)
                .padding(.bottom, 4)
                .padding(.horizontal, 4)
                .onChange(of: currentTag) { _, tag in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollProxy.scrollTo(tag, anchor: .center)
                    }
                }
            }
        }
    }

    private var sortedTags: [String] {
        Array(stateService.tags).sorted()
    }

    @ViewBuilder
    private func TagButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? .white : primaryTextColor)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
                .clipShape(Capsule())
        }
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private func ToolbarContent() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                TagFilterMenu()
                SortOrderMenu()
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if #unavailable(iOS 26.0) {
                    AddTokenButton()
                }
                SettingsButton()
            }

            // iOS 26+ bottom bar items
            if #available(iOS 26.0, *) {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    AddTokenButton()
                }
            }
        }
    }

    @ViewBuilder
    private func TagFilterMenu() -> some View {
        Menu {
            Button {
                currentTag = "All"
            } label: {
                Label("All", systemImage: currentTag == "All" ? "checkmark" : "")
            }

            ForEach(Array(stateService.tags).sorted(), id: \.self) { tag in
                Button {
                    currentTag = tag
                } label: {
                    Label(tag, systemImage: currentTag == tag ? "checkmark" : "")
                }
            }

            Divider()

            Button {
                showTagsManagementSheet = true
            } label: {
                Text("Manage Tags")
            }
        } label: {
            Label("Tag", systemImage: "tag")
        }
        .menuOrder(.fixed)
    }

    @ViewBuilder
    private func SortOrderMenu() -> some View {
        Menu {
            ForEach(sortOptions, id: \.criteria) { option in
                Button {
                    sortCriteria = option.criteria
                } label: {
                    Label(option.title, systemImage: sortCriteria == option.criteria ? "checkmark" : "")
                }
            }
        } label: {
            Label("Sort Order", systemImage: "line.3.horizontal.decrease")
        }
        .menuOrder(.fixed)
    }

    @ViewBuilder
    private func AddTokenButton() -> some View {
        Button {
            showTokenAddSheet.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }

    @ViewBuilder
    private func SettingsButton() -> some View {
        Button {
            showSettingsSheet.toggle()
        } label: {
            Image(systemName: "gearshape")
        }
    }

    private func EmptyStateView() -> some View {
        Group {
            if encryptedTokens.isEmpty {
                VStack {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                        .opacity(0.8)

                    Text("No tokens found. Add one by pressing the + icon at the top right corner or the button below.")
                        .padding(.top, 4)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .opacity(0.8)

                    Button {
                        showTokenAddSheet.toggle()
                    } label: {
                        Text("Add Token")
                            .padding(.horizontal, 4)
                            .bold()
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
            } else if tokenPairs.isEmpty && !searchQuery.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                        .opacity(0.8)

                    Text("No results found")
                        .padding(.top, 4)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .opacity(0.8)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func updateTokenPairs() async {
        guard loginStatus.loggedIn else {
            tokenPairs = []
            return
        }

        let decryptedPairs: [TokenPair] = encryptedTokens.compactMap { encToken in
            guard let decryptedToken = cryptoService.decryptToken(encryptedToken: encToken) else {
                return nil
            }
            return TokenPair(id: encToken.id, token: decryptedToken, encToken: encToken)
        }

        tokenPairs = decryptedPairs
        sortAndFilterTokenPairs()
    }

    private func sortAndFilterTokenPairs() {
        stateService.tags = Set(
            tokenPairs
                .flatMap { $0.token.tags ?? [] }
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        )

        if currentTag != "All", !stateService.tags.contains(currentTag) {
            currentTag = "All"
        }

        withAnimation {
            tokenPairs = tokenPairs
                .filter { tokenPair in
                    if currentTag == "All" {
                        return searchQuery.isEmpty ||
                            tokenPair.token.issuer.localizedCaseInsensitiveContains(searchQuery) ||
                            tokenPair.token.account.localizedCaseInsensitiveContains(searchQuery)
                    }

                    return (tokenPair.token.tags?.contains(currentTag) ?? false) &&
                        (searchQuery.isEmpty ||
                            tokenPair.token.issuer.localizedCaseInsensitiveContains(searchQuery) ||
                            tokenPair.token.account.localizedCaseInsensitiveContains(searchQuery))
                }
                .sorted { token1, token2 in
                    let pinned1 = token1.token.pinned ?? false
                    let pinned2 = token2.token.pinned ?? false

                    if pinned1 != pinned2 {
                        return pinned1
                    }

                    if pinned1 {
                        return token1.token.issuer.localizedCaseInsensitiveCompare(token2.token.issuer) == .orderedAscending
                    }

                    switch sortCriteria {
                    case .ISSUER_ASC:
                        return token1.token.issuer.localizedCaseInsensitiveCompare(token2.token.issuer) == .orderedAscending
                    case .ISSUER_DESC:
                        return token1.token.issuer.localizedCaseInsensitiveCompare(token2.token.issuer) == .orderedDescending
                    case .ACCOUNT_ASC:
                        return token1.token.account.localizedCaseInsensitiveCompare(token2.token.account) == .orderedAscending
                    case .ACCOUNT_DESC:
                        return token1.token.account.localizedCaseInsensitiveCompare(token2.token.account) == .orderedDescending
                    }
                }
        }
    }
}
