import Factory
import SwiftUI

struct VaultSetupView: View {
    let vaultService = Container.shared.vaultService()

    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false

    @State private var vaultName: String = ""
    @State private var isCreatingVault: Bool = false
    @State private var nextBtnPressed: Bool = false

    var body: some View {
        VStack {
            Image(systemName: "lock.shield")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text("A vault contains all of your Two-Factor Authentication (2FA) tokens and is secured with your own password.")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            Text("Your vault name")
                .padding(.top, 32)

            Group {
                TextField("", text: $vaultName)
                    .multilineTextAlignment(.center)
                    .background(Color.clear)
                    .onAppear {
                        if vaultName.isEmpty {
                            vaultName = isICloudEnabled ? "My Vault" : "My Offline Vault"
                        }
                    }
            }
            .frame(height: 48)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            Spacer()

            Button {
                nextBtnPressed = true
            } label: {
                if !isCreatingVault {
                    Text("Next")
                        .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                } else {
                    ProgressView()
                        .tint(Color(red: 0.04, green: 0, blue: 0.11))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
            .padding(.top, 64)
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(Color(red: 0.04, green: 0, blue: 0.11).ignoresSafeArea())
        .navigationTitle("Vault")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $nextBtnPressed) {
            PasswordSetupView(vaultName: vaultName)
        }
    }
}
