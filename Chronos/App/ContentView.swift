import Factory
import SwiftUI

struct ContentView: View {
    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loginStatus: LoginStatus

    let stateService = Container.shared.stateService()
    let swiftDataService = Container.shared.swiftDataService()

    var body: some View {
        if !stateOnboardingCompleted || !loginStatus.loggedIn {
            AuthenticationView()
        } else {
            MainAppView()
                .onChange(of: scenePhase) { _, newValue in
                    if newValue == .background {
                        loginStatus.loggedIn = false
                        stateService.clearMasterKey()
                    }
                }
                .modelContainer(swiftDataService.getModelContainer())
        }
    }
}
