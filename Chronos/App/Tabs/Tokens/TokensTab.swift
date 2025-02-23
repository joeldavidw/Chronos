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

class TokenPairsCache {
    var encryptedTokensHash: Int = 0
    var tokenPairs: [TokenPair] = []

    func update(encryptedTokensHash: Int, tokenPairs: [TokenPair]) {
        self.encryptedTokensHash = encryptedTokensHash
        self.tokenPairs = tokenPairs
    }
}

struct TokensTab: View {
    @Query private var vaults: [Vault]
    @EnvironmentObject var loginStatus: LoginStatus
    @Environment(\.colorScheme) var colorScheme

    @State private var showTokenAddSheet = false
    @State private var detentHeight: CGFloat = 0
    @State private var sortCriteria: TokenSortOrder = .ISSUER_ASC
    @State private var searchQuery = ""

    @State private var currentTag = "All"

    @State private var tokenPairs: [TokenPair] = []
    @State private var tokenPairsCache = TokenPairsCache()
    @State private var debounceTimer: Timer?

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
            TagsScrollBar()

            List(tokenPairs) { tokenPair in
                TokenRowView(tokenPair: tokenPair, timer: timer, triggerSortAndFilterTokenPairs: self.sortAndFilterTokenPairs)
            }
            .onAppear { Task { await updateTokenPairs() } }
            .onChange(of: encryptedTokens) { _, _ in
                Task { await updateTokenPairs() }
            }
            .onChange(of: sortCriteria) { _, _ in
                sortAndFilterTokenPairs()
            }
            .onChange(of: searchQuery) { _, _ in
                debounceTimer?.invalidate()
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    Task {
                        await sortAndFilterTokenPairs()
                    }
                }
            }
            .onChange(of: currentTag) { _, _ in
                sortAndFilterTokenPairs()
            }
            .listStyle(.plain)
            .navigationTitle(currentTag == "All" ? "Tokens" : currentTag)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text(currentTag == "All" ? "Search tokens" : "Search \"\(currentTag)\" tokens"))
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
            .animation(.default, value: UUID())
        }
    }

    private func TagsScrollBar() -> some View {
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

                ForEach(stateService.tags, id: \.self) { tag in
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
                }
            }
            .padding(.horizontal)
            .frame(height: 32)
        }
    }

    private func ToolbarContent() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .topBarLeading) {
                Menu {
                    Button {
                        currentTag = "All"
                    } label: {
                        Label("All", systemImage: currentTag == "All" ? "checkmark" : "")
                    }
                    ForEach(stateService.tags, id: \.self) { tag in
                        if tag != "All" {
                            Button {
                                currentTag = tag
                            } label: {
                                Label(tag, systemImage: currentTag == tag ? "checkmark" : "")
                            }
                        }
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

        if encryptedTokens.hashValue == tokenPairsCache.encryptedTokensHash {
            tokenPairs = tokenPairsCache.tokenPairs
            sortAndFilterTokenPairs()
            return
        }

        let decryptedPairs: [TokenPair] = encryptedTokens.compactMap { encToken in
            guard let decryptedToken = cryptoService.decryptToken(encryptedToken: encToken) else {
                return nil
            }
            return TokenPair(id: encToken.id, token: decryptedToken, encToken: encToken)
        }

        stateService.tags = Array(Set(decryptedPairs.flatMap { tokenPair in
            tokenPair.token.tags ?? []
        })).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

        tokenPairsCache.update(encryptedTokensHash: encryptedTokens.hashValue, tokenPairs: decryptedPairs)
        tokenPairs = decryptedPairs
        sortAndFilterTokenPairs()
    }

    private func sortAndFilterTokenPairs() {
        tokenPairs = tokenPairsCache.tokenPairs
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
