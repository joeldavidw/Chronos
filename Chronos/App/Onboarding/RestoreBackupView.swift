import Factory
import SwiftUI

struct RestoreBackupView: View {
    @State private var password: String = ""
    @State private var restoreBtnPressed: Bool = false
    @State private var passwordVerified: Bool = false
    @State private var passwordInvalid: Bool = false
    @State private var backupExists: Bool = false

    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false

    @FocusState private var focusedField: FocusedField?

    let cryptoService = Container.shared.cryptoService()

    var body: some View {
        VStack {
            Image(systemName: "ellipsis.rectangle")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text("Re-enter the master key used to setup Chronos previously")
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
                restoreBtnPressed = true

                Task {
                    passwordVerified = await cryptoService.unwrapMasterKeyWithUserPassword(password: Array(password.utf8), isRestore: true)
                    restoreBtnPressed = false

                    if passwordVerified {
                        isICloudEnabled = true
                    } else {
                        passwordInvalid = true
                        let notificationGenerator = UINotificationFeedbackGenerator()
                        notificationGenerator.notificationOccurred(.error)
                    }
                }
            } label: {
                if !restoreBtnPressed {
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
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .navigationTitle("Restore Backup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $passwordVerified) {
            BiometricsSetupView()
        }
        .background(Color(red: 0.04, green: 0, blue: 0.11).ignoresSafeArea())
        .onAppear {
            focusedField = .password
        }
    }
}
