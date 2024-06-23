import Factory
import SwiftData
import SwiftUI

struct MainAppView: View {
    @Query private var vaults: [Vault]

    @State private var currentTab: String = "Tokens"

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loginStatus: LoginStatus

    @AppStorage(StateEnum.LAST_ICLOUD_SYNC.rawValue) var lastIcloudSync: TimeInterval = 0

    private let stateService = Container.shared.stateService()

    private var filteredVault: [Vault] {
        return vaults.compactMap { vault in
            vault.vaultId == stateService.getVaultId() ? vault : nil
        }
    }

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
            if filteredVault.isEmpty {
                stateService.resetAllStates()
                loginStatus.loggedIn = false
            }
        }
        .onChange(of: filteredVault) { _, newValue in
            if newValue.isEmpty {
                stateService.resetAllStates()
                loginStatus.loggedIn = false
            }
        }
    }
}
