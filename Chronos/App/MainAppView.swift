import Factory
import SwiftData
import SwiftUI

struct MainAppView: View {
    @State private var currentTab: String = "Tokens"

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loginStatus: LoginStatus

    @Query var chronosCryptos: [ChronosCrypto]

    let stateService = Container.shared.stateService()

    var body: some View {
        ZStack {
            TabView(selection: $currentTab) {
                TokensTab()
                    .tag("Tokens")
                    .tabItem {
                        Label("Tokens", systemImage: "lock.fill")
                    }

                SettingsTab()
                    .tag("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }

            if scenePhase != .active {
                PrivacyView()
            }
        }
        .onAppear {
            if chronosCryptos.isEmpty {
                stateService.resetAllStates()
                loginStatus.loggedIn = false
            }
        }
        .onChange(of: chronosCryptos) { _, newValue in
            if newValue.isEmpty {
                stateService.resetAllStates()
                loginStatus.loggedIn = false
            }
        }
    }
}
