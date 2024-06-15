import Factory
import SwiftData
import SwiftUI

struct TokenPair: Identifiable {
    var id: ObjectIdentifier

    var token: Token
    var encToken: EncryptedToken
}

struct TokensTab: View {
    @Query(sort: \EncryptedToken.createdAt) private var encryptedTokens: [EncryptedToken]

    @State private var showTokenAddSheet = false
    @State private var showTokenUpdateSheet = false
    @State private var showTokenDeleteSheet = false

    @State private var selectedTokenForDeletion: Token? = nil
    @State private var selectedTokenForUpdate: Token? = nil
    @State var detentHeight: CGFloat = 0

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()

    private var tokenPairs: [TokenPair] {
        let vaultId = stateService.getVaultId()

        return encryptedTokens.filter { $0.vault?.vaultId == vaultId }
            .compactMap { encToken in
                guard let decryptedToken = cryptoService.decryptToken(encryptedToken: encToken) else {
                    return nil
                }
                return TokenPair(id: encToken.id, token: decryptedToken, encToken: encToken)
            }
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
