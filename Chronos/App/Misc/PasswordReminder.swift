import AlertKit
import Factory
import SwiftData
import SwiftUI

struct PasswordReminderView: View {
    @Environment(\.dismiss) var dismiss

    @State private var verifyPressed: Bool = false
    @State private var password: String = ""
    @State private var passwordInvalid: Bool = false

    @FocusState private var focusedField: FocusedField?

    @AppStorage(StateEnum.PASSWORD_REMINDER_ENABLED.rawValue) private var statePasswordReminderEnabled: Bool = true
    @AppStorage(StateEnum.NEXT_PASSWORD_REMINDER_TIMESTAMP.rawValue) var nextPasswordReminderTimestamp: TimeInterval = 0

    let cryptoService = Container.shared.cryptoService()
    let vaultService = Container.shared.vaultService()
    let swiftDataService = Container.shared.swiftDataService()

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "lock.circle.dotted")
                    .font(.system(size: 44))
                    .padding(.bottom, 16)

                Text("This is an occasional prompt to ensure you don’t forget your password.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                Group {
                    HStack {
                        SecureField("Enter your password", text: $password)
                            .background(Color.clear)
                            .focused($focusedField, equals: .password)
                            .disabled(verifyPressed)
                            .submitLabel(.done)
                            .onSubmit {
                                Task {
                                    await doSubmit()
                                }
                            }
                    }
                }
                .frame(height: 48)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.top, 32)

                if passwordInvalid {
                    Text("Invalid password. Check your password and try again.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .padding(.top, 4)
                }

                Button {
                    Task {
                        await doSubmit()
                    }
                } label: {
                    if !verifyPressed {
                        Text("Verify")
                            .bold()
                            .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 32)
                            .disabled(verifyPressed)
                    } else {
                        ProgressView()
                            .tint(Color(red: 0.04, green: 0, blue: 0.11))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 32)
                    }
                }
                .padding(.top, 32)
                .buttonStyle(.borderedProminent)

                Button {
                    dismiss()
                } label: {
                    Text("Skip")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderless)
            }
            .padding(16)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.04, green: 0, blue: 0.11).ignoresSafeArea())
            .navigationTitle("Password Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                focusedField = .password

                nextPasswordReminderTimestamp = Date().timeIntervalSince1970 + (2 * 7 * 24 * 60 * 60)
            }
        }
        .presentationDragIndicator(.visible)
    }

    func doSubmit() async {
        verifyPressed = true

        let context = ModelContext(swiftDataService.getModelContainer())
        let vault = vaultService.getVault(context: context)!

        let passwordVerified = await cryptoService.unwrapMasterKeyWithUserPassword(vault: vault, password: Array(password.utf8))

        if passwordVerified {
            dismiss()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            passwordInvalid = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        verifyPressed = false
    }
}
