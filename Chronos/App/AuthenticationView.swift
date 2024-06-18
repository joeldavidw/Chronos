import Factory
import SwiftUI

struct AuthenticationView: View {
    let swiftDataService = Container.shared.swiftDataService()

    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false

    var body: some View {
        Group {
            if !stateOnboardingCompleted {
                WelcomeView()
                    // Defaults to a cloud container for SwiftUI on the first load. Allows SwiftData in SwiftUI to retrieve vaults from CloudKit.
                    .modelContainer(swiftDataService.getCloudModelContainer())
            } else {
                PasswordLoginView()
            }
        }
    }
}
