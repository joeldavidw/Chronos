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

struct TokensTab: View {
    @Query private var vaults: [Vault]
    @EnvironmentObject var loginStatus: LoginStatus
    @Environment(\.colorScheme) var colorScheme

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
            List(tokenPairs) { tokenPair in
                TokenRowView(tokenPair: tokenPair, timer: timer, triggerSortAndFilterTokenPairs: self.sortAndFilterTokenPairs)
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
            .toolbarBackground(isSearchablePresented ? .visible : .hidden, for: .navigationBar)
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
            .searchable(text: $searchQuery,
                        isPresented: $isSearchablePresented,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: Text(currentTag == "All" ? "Search tokens" : "Search \"\(currentTag)\" tokens"))
            .safeAreaInset(edge: .top, spacing: 0) {
                if !isSearchablePresented {
                    TagsScrollBar()
                } else {
                    Divider()
                }
            }
        }
    }

    private func TagsScrollBar() -> some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        Button {
                            currentTag = "All"
                        } label: {
                            Text("All")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundStyle(currentTag == "All" ? .white : (colorScheme == .dark ? .white : .black))
                                .background(currentTag == "All" ? Color.accentColor : Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                        .id("All")
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            tagsButtonHeight = height
                        }

                        ForEach(Array(stateService.tags).sorted(), id: \.self) { tag in
                            Button {
                                currentTag = tag
                            } label: {
                                Text(tag)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .foregroundStyle(currentTag == tag ? .white : (colorScheme == .dark ? .white : .black))
                                    .background(currentTag == tag ? Color.accentColor : Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                            .id(tag)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: tagsButtonHeight)
                }
                .padding(.top, 2)
                .padding(.bottom, 8)
                .padding(.horizontal, 4)
                .background(Color.clear.overlay(.ultraThinMaterial))
                .onChange(of: currentTag) { _, tag in
                    withAnimation {
                        scrollProxy.scrollTo(tag, anchor: .center)
                    }
                }
            }
            Divider()
        }
    }

    private func ToolbarContent() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                Menu {
                    Button {
                        currentTag = "All"
                    } label: {
                        HStack {
                            Text("All")
                            if currentTag == "All" {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    ForEach(Array(stateService.tags).sorted(), id: \.self) { tag in
                        if tag != "All" {
                            Button {
                                currentTag = tag
                            } label: {
                                HStack {
                                    Text(tag)
                                    if currentTag == tag {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
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

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(sortOptions, id: \.criteria) { option in
                        Button {
                            sortCriteria = option.criteria
                        } label: {
                            if sortCriteria == option.criteria {
                                Label(option.title, systemImage: "checkmark")
                            } else {
                                Text(option.title)
                            }
                        }
                    }
                } label: {
                    Label("Sort Order", systemImage: "arrow.up.arrow.down")
                }
                .menuOrder(.fixed)

                Button {
                    showTokenAddSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
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

        if currentTag != "All" && !stateService.tags.contains(currentTag) {
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
