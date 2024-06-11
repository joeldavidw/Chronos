import Factory
import SwiftUI

struct AuthenticationView: View {
    let swiftDataService = Container.shared.swiftDataService()

    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false

    var body: some View {
        Group {
            if !stateOnboardingCompleted {
                WelcomeView()
            } else {
                PasswordLoginView()
            }
        }
        .modelContainer(swiftDataService.getCloudModelContainer())
    }
}
