import Factory
import SwiftData
import SwiftUI

struct RestoreBackupView: View {
    @State private var password: String = ""
    @State private var restoreBtnPressed: Bool = false
    @State private var passwordVerified: Bool = false
    @State private var passwordInvalid: Bool = false
    @State private var backupExists: Bool = false

    @Query var vaults: [Vault]

    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false

    @FocusState private var focusedField: FocusedField?

    let cryptoService = Container.shared.cryptoService()
    let vaultService = Container.shared.vaultService()
    let stateService = Container.shared.stateService()

    var body: some View {
        VStack {
            Image(systemName: "ellipsis.rectangle")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text("Re-enter the master password used to setup Chronos previously")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("Your master password")
                .font(.subheadline)
                .padding(.top, 32)

            Group {
                SecureField("", text: $password)
                    .multilineTextAlignment(.center)
                    .background(Color.clear)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        Task {
                            await doSubmit()
                        }
                    }
            }
            .frame(height: 48)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if passwordInvalid {
                Text("Invalid password. Check your password and try again.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            }

            Spacer()

            Button {
                Task {
                    await doSubmit()
                }
            } label: {
                if !restoreBtnPressed {
                    Text("Next")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                } else {
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .navigationTitle("Restore Backup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $passwordVerified) {
            BiometricsSetupView()
        }
        .onAppear {
            focusedField = .password
        }
    }

    func doSubmit() async {
        // Defaults to the first vault if the user is not coming from VaultSelectionView.
        // Users will only come from VaultSelectionView if there are multiple vaults.
        if vaults.count == 1 {
            stateService.setVaultId(vaultId: vaults.first!.vaultId!)
        }

        restoreBtnPressed = true

        let vault = vaultService.getVaultWithoutContext(isRestore: true)

        passwordVerified = await cryptoService.unwrapMasterKeyWithUserPassword(vault: vault, password: Array(password.utf8), isRestore: true)
        restoreBtnPressed = false

        if passwordVerified {
            isICloudEnabled = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            passwordInvalid = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
