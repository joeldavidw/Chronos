import AlertKit
import Factory
import SwiftUI

struct ImportConfirmationView: View {
    @State var tokens: [Token]?

    @EnvironmentObject var importNav: ExportNavigation

    let cryptoService = Container.shared.cryptoService()
    let vaultService = Container.shared.vaultService()

    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            if let tokens = tokens {
                Text("\(tokens.count) tokens are ready to be imported. Would you like to proceed with the import?")
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
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
                } label: {
                    Text("Import")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)
                
                Button {
                    importNav.showSheet = false
                } label: {
                    Text("Cancel")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderless)
            } else {
                Text("Error")
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Confirm Import")
        .padding([.horizontal], 24)
        .padding([.bottom], 32)
        .navigationBarTitleDisplayMode(.inline)
    }
}
