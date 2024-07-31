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
    var vaultsHash: Int = 0
    var tokenPairs: [TokenPair] = []

    func update(vaultsHash: Int, tokenPairs: [TokenPair]) {
        self.vaultsHash = vaultsHash
        self.tokenPairs = tokenPairs
    }
}

struct TokensTab: View {
    @Query private var vaults: [Vault]

    @EnvironmentObject var loginStatus: LoginStatus

    @State private var showTokenAddSheet = false
    @State private var detentHeight: CGFloat = 0
    @State private var sortCriteria: TokenSortOrder = .ISSUER_ASC
    @State private var searchQuery = ""

    @State private var filteredAndSortedTokenPairs: [TokenPair] = []
    @State private var tokenPairsCache = TokenPairsCache()

    @State private var timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common).autoconnect()

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()

    var body: some View {
        NavigationStack {
            List(filteredAndSortedTokenPairs) { tokenPair in
                TokenRowView(tokenPair: tokenPair, timer: timer)
            }
            .onAppear {
                Task {
                    await updateTokenPairs()
                }
            }
            .onChange(of: vaults) { _, _ in
                Task {
                    await updateTokenPairs()
                }
            }
            .onChange(of: sortCriteria) { _, _ in
                updateFilteredAndSortedTokenPairs()
            }
            .onChange(of: searchQuery) { _, _ in
                updateFilteredAndSortedTokenPairs()
            }
            .listStyle(.plain)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationTitle("Tokens")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, prompt: Text("Search tokens"))
            .toolbar {
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
            .overlay(
                Group {
                    if filteredAndSortedTokenPairs.isEmpty {
                        VStack {
                            Image(systemName: searchQuery.isEmpty ? "qrcode.viewfinder" : "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)
                                .opacity(0.8)

                            Text(searchQuery.isEmpty ? "No tokens found. Add one by pressing the + icon at the top right corner or the button below." : "No results found")
                                .padding(.top, 4)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .opacity(0.8)

                            if searchQuery.isEmpty {
                                Button {
                                    showTokenAddSheet.toggle()
                                } label: {
                                    Text("Add Token")
                                        .padding(.horizontal, 4)
                                        .bold()
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            )
            .sheet(isPresented: $showTokenAddSheet) {
                AddTokenView()
                    .getSheetHeight()
                    .onPreferenceChange(SheetHeightPreferenceKey.self) { height in
                        self.detentHeight = height
                    }
                    .presentationDetents([.height(self.detentHeight)])
            }
        }
    }

    func updateTokenPairs() async {
        guard loginStatus.loggedIn else {
            filteredAndSortedTokenPairs = []
            return
        }

        let vaultId = stateService.getVaultId()
        guard let vault = vaults.first(where: { $0.vaultId == vaultId }) else {
            filteredAndSortedTokenPairs = []
            return
        }

        if vaults.hashValue == tokenPairsCache.vaultsHash {
            filteredAndSortedTokenPairs = tokenPairsCache.tokenPairs
            return
        }

        let decryptedPairs: [TokenPair] = (vault.encryptedTokens ?? []).compactMap { encToken in
            guard let decryptedToken = cryptoService.decryptToken(encryptedToken: encToken) else {
                return nil
            }
            return TokenPair(id: encToken.id, token: decryptedToken, encToken: encToken)
        }

        tokenPairsCache.update(vaultsHash: vaults.hashValue, tokenPairs: decryptedPairs)
        updateFilteredAndSortedTokenPairs()
    }

    func updateFilteredAndSortedTokenPairs() {
        let filteredPairs: [TokenPair] = tokenPairsCache.tokenPairs.filter { tokenPair in
            searchQuery.isEmpty ||
                tokenPair.token.issuer.localizedCaseInsensitiveContains(searchQuery) ||
                tokenPair.token.account.localizedCaseInsensitiveContains(searchQuery)
        }

        filteredAndSortedTokenPairs = filteredPairs.sorted { token1, token2 in
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
