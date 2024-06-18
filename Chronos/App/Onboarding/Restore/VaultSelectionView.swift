import AlertKit
import Factory
import SwiftData
import SwiftUI

struct VaultSelectionView: View {
    @Query(sort: \Vault.createdAt) var vaults: [Vault]

    @State private var moveToNextScreen: Bool = false

    let cryptoService = Container.shared.cryptoService()
    let vaultService = Container.shared.vaultService()
    let stateService = Container.shared.stateService()

    let formatter = RelativeDateTimeFormatter()

    var body: some View {
        VStack {
            ScrollViewReader { _ in
                List(vaults) { vault in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vault.name)
                                .fontWeight(.semibold)

                            Text("Created \(formatter.localizedString(for: Date(timeIntervalSince1970: vault.createdAt!.timeIntervalSince1970), relativeTo: Date.now))")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("\(vault.encryptedTokens?.count ?? 0)")
                                .font(.system(size: 20))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.gray).opacity(0.6))
                                .cornerRadius(8)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard let vaultId = vault.vaultId else {
                            AlertKitAPI.present(
                                title: "Unable to access vault",
                                icon: .error,
                                style: .iOS17AppleMusic,
                                haptic: .error
                            )
                            return
                        }

                        stateService.setVaultId(vaultId: vaultId)
                        moveToNextScreen = true
                    }
                    .padding(CGFloat(4))
                }
                .listStyle(.plain)
            }
        }
        .navigationDestination(isPresented: $moveToNextScreen) {
            RestoreBackupView()
        }
        .navigationTitle("Vaults")
    }
}
