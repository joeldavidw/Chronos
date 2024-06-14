import Factory
import SwiftData
import SwiftUI

struct TokensTab: View {
    @Query(sort: \EncryptedToken.createdAt) private var encyptedTokens: [EncryptedToken]

    @State private var showTokenAddSheet = false
    @State private var showTokenUpdateSheet = false
    @State private var showTokenDeleteSheet = false

    @State private var selectedTokenForDeletion: Token? = nil
    @State private var selectedTokenForUpdate: Token? = nil
    @State var detentHeight: CGFloat = 0

    let stateService = Container.shared.stateService()

    private var filteredEncyptedTokens: [EncryptedToken] {
        return encyptedTokens.compactMap { encToken in
            encToken.vault?.vaultId == stateService.getVaultId() ? encToken : nil
        }
    }

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollViewReader { _ in
                    List(filteredEncyptedTokens) { encyptedToken in
                        TokenRowView(tokenRowViewModel: TokenRowViewModel(encyptedToken: encyptedToken))
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
            }.onAppear {
                stateService.getAllStates()
            }
        }
    }
}
