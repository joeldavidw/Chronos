import AlertKit
import Factory
import SwiftUI

struct PasswordLoginView: View {
    @EnvironmentObject var loginStatus: LoginStatus
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false
    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false
    @AppStorage(StateEnum.LAST_BIOMETRICS_AUTH_ATTEMPT.rawValue) var stateLastBiometricsAuthAttempt: TimeInterval = .init(0)

    @State private var loginPressed: Bool = false
    @State private var password: String = ""
    @State private var passwordInvalid: Bool = false

    @FocusState private var focusedField: FocusedField?

    let cryptoService = Container.shared.cryptoService()
    let stateService = Container.shared.stateService()
    let vaultService = Container.shared.vaultService()
    let secureEnclaveService = Container.shared.secureEnclaveService()

    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .frame(width: 96, height: 96)

            Group {
                HStack {
                    SecureField("Enter your master password", text: $password)
                        .background(Color.clear)
                        .focused($focusedField, equals: .password)
                        .disabled(loginPressed)
                        .submitLabel(.done)
                        .onSubmit {
                            doSubmit()
                        }

                    if stateBiometricsAuth {
                        Button {
                            biometricsAuthLogin()
                        } label: {
                            Image(systemName: "faceid")
                                .font(.system(size: 24))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 48)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if passwordInvalid {
                Text("Invalid password. Check your password and try again.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.red)
                    .font(.subheadline)
                    .padding(.top, 4)
            }

            Button {
                doSubmit()
            } label: {
                if !loginPressed {
                    Text("Login")
                        .bold()
                        .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                        .disabled(loginPressed)
                } else {
                    ProgressView()
                        .tint(Color(red: 0.04, green: 0, blue: 0.11))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
            .padding(.top, 32)
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color(red: 0.04, green: 0, blue: 0.11).ignoresSafeArea())
        .navigationTitle("Welcome Back")
        .onAppear {
            focusedField = .password
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if stateBiometricsAuth {
                if oldValue == .inactive && newValue == .active && Date().timeIntervalSince1970 - stateLastBiometricsAuthAttempt > 10 {
                    biometricsAuthLogin()
                }
            }
        }
    }
}

extension PasswordLoginView {
    func doSubmit() {
        loginPressed = true
        focusedField = nil

        Task {
            let vault = vaultService.getVaultWithoutContext(isRestore: false)

            let passwordVerified = await cryptoService.unwrapMasterKeyWithUserPassword(vault: vault, password: Array(password.utf8))

            if passwordVerified {
                loginStatus.loggedIn = true

                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                loginPressed = false
                passwordInvalid = true

                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    focusedField = .password
                }

                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    func biometricsAuthLogin() {
        stateLastBiometricsAuthAttempt = Date().timeIntervalSince1970

        guard let securedMasterKey = secureEnclaveService.getMasterKey()
        else {
            AlertKitAPI.present(
                title: "Unable to retrieve master key",
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )

            return
        }

        stateService.masterKey = securedMasterKey
        loginStatus.loggedIn = true
    }
}
