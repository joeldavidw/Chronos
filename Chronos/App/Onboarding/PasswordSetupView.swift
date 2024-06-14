import Factory
import SwiftData
import SwiftUI

enum FocusedField {
    case password, verifyPassword
}

struct PasswordSetupView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    @State private var nextBtnPressed: Bool = false
    @State private var isEncrypting: Bool = false

    @Query() private var vaults: [Vault]

    @FocusState private var focusedField: FocusedField?

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()

    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: "ellipsis.rectangle")
                    .font(.system(size: 44))
                    .padding(.bottom, 16)

                Text("Your master password is used to encrypt your data securely. Choose a memorable, random, and unique password with at least 10 characters.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                Text("Your master password")
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

                Text("Confirm your master password")
                    .padding(.top, 24)
                Group {
                    SecureField("", text: $verifyPassword)
                        .multilineTextAlignment(.center)
                        .background(Color.clear)
                        .focused($focusedField, equals: .verifyPassword)
                }
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Spacer()

                Button {
                    isEncrypting = true

                    Task {
                        await generateAndEncryptMasterKey()
                    }
                } label: {
                    if !isEncrypting {
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
                .disabled(!isPasswordValid)
                .padding(.top, 64)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
        }
        .background(Color(red: 0.04, green: 0, blue: 0.11).ignoresSafeArea())
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $nextBtnPressed) {
            BiometricsSetupView()
        }
        .onAppear {
            focusedField = .password
        }
    }
}

extension PasswordSetupView {
    func generateAndEncryptMasterKey() async {
        stateService.masterKey = try! cryptoService.generateRandomMasterKey()

        let vault = Vault(vaultId: UUID(), createdAt: Date(), chronosCryptos: [], encryptedTokens: [])
        modelContext.insert(vault)

        await cryptoService.wrapMasterKeyWithUserPassword(password: Array(password.utf8))
        nextBtnPressed = true
    }
}

extension PasswordSetupView {
    var isPasswordValid: Bool {
        var valid = true

        if password != verifyPassword {
            valid = false
        }

        if password.count < 10 {
            valid = false
        }

        return valid
    }
}
