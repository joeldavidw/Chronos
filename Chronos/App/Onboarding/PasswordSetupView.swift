import Factory
import SwiftUI

enum FocusedField {
    case password, verifyPassword
}

struct PasswordSetupView: View {
    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    @State private var nextBtnPressed: Bool = false
    @State private var isEncrypting: Bool = false
    @State private var passwordInvalidMsg: String = ""
    @State private var isPasswordValid: Bool = false

    @FocusState private var focusedField: FocusedField?

    let vaultName: String

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()
    let vaultService = Container.shared.vaultService()

    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "ellipsis.rectangle")
                    .font(.system(size: 44))
                    .padding(.bottom, 16)

                Text("Your master password is used to securely encrypt your tokens in a vault. Choose a memorable, random, and unique password with at least 10 characters.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                Text("Your master password")
                    .padding(.top, 32)

                Group {
                    SecureField("", text: $password)
                        .multilineTextAlignment(.center)
                        .background(Color.clear)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .verifyPassword
                        }
                        .onChange(of: password) { _, _ in
                            validatePasswords()
                        }
                }
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Text("Confirm your master password")
                    .padding(.top, 24)
                Group {
                    SecureField("", text: $verifyPassword)
                        .multilineTextAlignment(.center)
                        .background(Color.clear)
                        .focused($focusedField, equals: .verifyPassword)
                        .submitLabel(.done)
                        .onSubmit {
                            doSubmit()
                        }
                        .onChange(of: verifyPassword) { _, _ in
                            validatePasswords()
                        }
                }
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                if !isPasswordValid {
                    Text(passwordInvalidMsg)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .padding(.top, 4)
                }

                Spacer()

                Button {
                    doSubmit()
                } label: {
                    if !isEncrypting {
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
                .disabled(!isPasswordValid)
                .padding(.top, 64)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
        }
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $nextBtnPressed) {
            BiometricsSetupView()
        }
        .onAppear {
            focusedField = .password
        }
    }

    func doSubmit() {
        if !isPasswordValid {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        isEncrypting = true
        Task {
            await generateAndEncryptMasterKey()
        }
    }
}

extension PasswordSetupView {
    func generateAndEncryptMasterKey() async {
        stateService.masterKey = try! cryptoService.generateRandomMasterKey()

        let chronosCrypto = await cryptoService.wrapMasterKeyWithUserPassword(password: Array(password.utf8))

        let success = vaultService.createVaultCrypto(vaultName: vaultName, chronosCrypto: chronosCrypto)

        if success {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        nextBtnPressed = success
    }
}

extension PasswordSetupView {
    private func validatePasswords() {
        if password.count < 10 {
            isPasswordValid = false
            passwordInvalidMsg = "Passwords must be at least 10 characters long"
        } else if password != verifyPassword {
            isPasswordValid = false
            passwordInvalidMsg = "Passwords do not match"
        } else {
            isPasswordValid = true
            passwordInvalidMsg = ""
        }
    }
}
