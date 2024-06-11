import Factory
import SwiftUI

struct BiometricsSetupView: View {
    @EnvironmentObject var loginStatus: LoginStatus

    @State private var nextBtnPressed: Bool = false

    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false

    let secureEnclaveService = Container.shared.secureEnclaveService()

    @State private var bioMetricsImage: String = "faceid"

    var body: some View {
        VStack {
            Image(systemName: "faceid")
                .font(.system(size: 44))
                .padding(.bottom, 24)

            Text("With biometrics authentication enabled, you can easily unlock Chronos.")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                activateBiometricsAuth()

                loginStatus.loggedIn = true

                stateBiometricsAuth = true
                stateOnboardingCompleted = true
            } label: {
                Text("Enable Biometrics")
                    .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .padding(.top, 64)
            .buttonStyle(.borderedProminent)

            Button {
                stateBiometricsAuth = false
                loginStatus.loggedIn = true
                stateOnboardingCompleted = true
            } label: {
                Text("Continue without Biometrics")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .navigationTitle("Biometrics")
        .background(Color(red: 0.04, green: 0, blue: 0.11))
        .navigationBarBackButtonHidden()
    }

    func activateBiometricsAuth() {
        secureEnclaveService.saveMasterKey()
    }
}
