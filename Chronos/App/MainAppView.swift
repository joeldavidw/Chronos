import CloudKitSyncMonitor
import Factory
import SwiftData
import SwiftUI

struct MainAppView: View {
    @Query private var vaults: [Vault]

    @State private var currentTab: String = "Tokens"
    @State private var showPasswordReminder = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loginStatus: LoginStatus

    @ObservedObject var syncMonitor = SyncMonitor.shared

    @AppStorage(StateEnum.ICLOUD_SYNC_LAST_ATTEMPT.rawValue) var iCloudSyncLastAttempt: TimeInterval = 0
    @AppStorage(StateEnum.NEXT_PASSWORD_REMINDER_TIMESTAMP.rawValue) var nextPasswordReminderTimestamp: TimeInterval = 0
    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) var biometricsEnabled: Bool = false
    @AppStorage(StateEnum.PASSWORD_REMINDER_ENABLED.rawValue) private var statePasswordReminderEnabled: Bool = true

    private let stateService = Container.shared.stateService()

    private var filteredVault: [Vault] {
        return vaults.compactMap { vault in
            vault.vaultId == stateService.getVaultId() ? vault : nil
        }
    }

    var body: some View {
        if scenePhase != .active {
            PrivacyView()
        } else {
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
            .onAppear {
                if filteredVault.isEmpty {
                    stateService.resetAllStates()
                    loginStatus.loggedIn = false
                }

                if biometricsEnabled && statePasswordReminderEnabled {
                    if nextPasswordReminderTimestamp == 0 {
                        nextPasswordReminderTimestamp = Date().timeIntervalSince1970 + (2 * 7 * 24 * 60 * 60)
                    }

                    if Date().timeIntervalSince1970 >= nextPasswordReminderTimestamp {
                        showPasswordReminder = true
                    }
                }
            }
            .onChange(of: filteredVault) { _, newValue in
                if newValue.isEmpty {
                    stateService.resetAllStates()
                    loginStatus.loggedIn = false
                }
            }
            .onChange(of: syncMonitor.syncStateSummary) { _, newValue in
                if newValue == .succeeded {
                    iCloudSyncLastAttempt = Date().timeIntervalSince1970
                }
            }
            .sheet(isPresented: $showPasswordReminder, content: {
                PasswordReminderView()
            })
        }
    }
}
