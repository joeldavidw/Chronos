import AlertKit
import Factory
import SwiftUI

struct ImportConfirmationView: View {
    @State var tokens: [Token]

    @EnvironmentObject var importNav: ExportNavigation

    private let cryptoService = Container.shared.cryptoService()
    private let vaultService = Container.shared.vaultService()

    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text("**\(tokens.count) tokens** are ready to be imported.\nWould you like to proceed with the import?")
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: importTokens) {
                Text("Import")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)

            Button(action: { importNav.showSheet = false }) {
                Text("Cancel")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("Confirm Import")
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func importTokens() {
        for token in tokens {
            let newEncToken = cryptoService.encryptToken(token: token)
            vaultService.insertEncryptedToken(newEncToken)
        }

        importNav.showSheet = false

        AlertKitAPI.present(
            title: "Successfully imported tokens",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
}
