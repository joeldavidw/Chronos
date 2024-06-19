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

    @State private var showTokenAddSheet = false
    @State private var showTokenUpdateSheet = false
    @State private var showTokenDeleteSheet = false

    @State private var selectedTokenForDeletion: Token? = nil
    @State private var selectedTokenForUpdate: Token? = nil
    @State var detentHeight: CGFloat = 0
    @State var sortCriteria: TokenSortOrder = .ISSUER_ASC

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()

    private var tokenPairs: [TokenPair] {
        // This is necessary because tokenPairs is a computed property. It gets recomputed whenever stateService changes, such as when stateService.masterKey gets cleared.
        if !loginStatus.loggedIn {
            return []
        }

        let vaultId = stateService.getVaultId()
        guard let vault = vaults.filter({ $0.vaultId == vaultId }).first else {
            return []
        }

        let tokenPairs: [TokenPair] = vault.encryptedTokens?.compactMap { encToken in
            guard let decryptedToken = cryptoService.decryptToken(encryptedToken: encToken) else {
                return nil
            }
            return TokenPair(id: encToken.id, token: decryptedToken, encToken: encToken)
        }
        .sorted(by: { token1, token2 in
            switch sortCriteria {
            case .ISSUER_ASC:
                token1.token.issuer.localizedCaseInsensitiveCompare(token2.token.issuer) == .orderedAscending
            case .ISSUER_DESC:
                token1.token.issuer.localizedCaseInsensitiveCompare(token2.token.issuer) == .orderedDescending
            case .ACCOUNT_ASC:
                token1.token.account.localizedCaseInsensitiveCompare(token2.token.account) == .orderedAscending
            case .ACCOUNT_DESC:
                token1.token.account.localizedCaseInsensitiveCompare(token2.token.account) == .orderedDescending
            }
        }) ?? []

        return tokenPairs
    }

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollViewReader { _ in
                    List(tokenPairs) { tokenPair in
                        TokenRowView(tokenPair: tokenPair)
                    }
                    .listStyle(.plain)
                }
                .background(Color(red: 0.04, green: 0, blue: 0.11))
                .navigationTitle("Tokens")
                .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}
