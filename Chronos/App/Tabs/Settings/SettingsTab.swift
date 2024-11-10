import CloudKitSyncMonitor
import Factory
import SwiftUI

final class ExportNavigation: ObservableObject {
    @Published var showSheet = false
}

struct SettingsTab: View {
    @EnvironmentObject private var loginStatus: LoginStatus
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) private var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) private var isICloudEnabled: Bool = false
    @AppStorage(StateEnum.ICLOUD_SYNC_LAST_ATTEMPT.rawValue) private var iCloudSyncLastAttempt: TimeInterval = 0

    @AppStorage(StateEnum.PASSWORD_REMINDER_ENABLED.rawValue) private var statePasswordReminderEnabled: Bool = true
    @AppStorage(StateEnum.NEXT_PASSWORD_REMINDER_TIMESTAMP.rawValue) var nextPasswordReminderTimestamp: TimeInterval = 0

    @AppStorage(StateEnum.TAP_TO_REVEAL_ENABLED.rawValue) private var stateTapToRevealEnabled: Bool = false
    @AppStorage(StateEnum.PREVIOUS_TOKEN_ENABLED.rawValue) private var statePreviousTokenEnabled: Bool = false

    @StateObject private var exportNav = ExportNavigation()
    @StateObject private var importNav = ExportNavigation()

    private let secureEnclaveService = Container.shared.secureEnclaveService()
    private let swiftDataService = Container.shared.swiftDataService()
    private let stateService = Container.shared.stateService()

    @State private var showExportJsonConfirmation: Bool = false

    @State private var showLogoutConfirmation = false
    @State private var lastSyncedText = "Syncing..."

    let timer = Timer.publish(every: 1, tolerance: 1, on: .main, in: .common).autoconnect()
    let formatter = RelativeDateTimeFormatter()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Storage")) {
                    Toggle(isOn: $isICloudEnabled, label: {
                        Text("iCloud Backup")
                    }).disabled(true)

                    LabeledContent {
                        if isICloudEnabled {
                            Text(lastSyncedText)
                        } else {
                            Text("Offline")
                        }
                    } label: {
                        Text("Last Synced")
                    }
                    .onReceive(timer) { _ in
                        lastSyncedText = formatter.localizedString(for: Date(timeIntervalSince1970: iCloudSyncLastAttempt), relativeTo: Date.now)
                        if lastSyncedText.starts(with: "in") {
                            lastSyncedText = "Syncing..."
                        }

                        if iCloudSyncLastAttempt == Date().timeIntervalSince1970 {
                            lastSyncedText = "Not Started"
                        }
                    }
                }

                Section {
                    Button {
                        importNav.showSheet = true
                    } label: {
                        Text("Import")
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .sheet(isPresented: $importNav.showSheet, content: {
                        ImportSourceListView()
                            .environmentObject(importNav)
                    })
                }
                .listSectionSpacing(8)

                Section {
                    Button {
                        exportNav.showSheet = true
                    } label: {
                        Text("Export")
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .sheet(isPresented: $exportNav.showSheet, content: {
                        ExportSelectionView()
                            .environmentObject(exportNav)
                    })
                    .onChange(of: scenePhase) { _, newValue in
                        if newValue != .active {
                            exportNav.showSheet = false
                        }
                    }
                }
                .listSectionSpacing(8)

                Section(header: Text("Security")) {
                    Toggle(isOn: $stateBiometricsAuth, label: {
                        Text("Biometics Authentication")
                    })
                    .onChange(of: stateBiometricsAuth) { _, enabled in
                        if enabled {
                            secureEnclaveService.saveMasterKey()
                        } else {
                            secureEnclaveService.deleteMasterKey()
                        }
                    }

                    if stateBiometricsAuth {
                        Toggle(isOn: $statePasswordReminderEnabled, label: {
                            Text("Password Reminder (2 Weeks)")
                        })
                        .onChange(of: statePasswordReminderEnabled) { _, enabled in
                            if enabled {
                                nextPasswordReminderTimestamp = Date().timeIntervalSince1970 + (2 * 7 * 24 * 60 * 60)
                            }
                        }
                    }

                    Toggle(isOn: $stateTapToRevealEnabled, label: {
                        Text("Tap to reveal")
                    })
                    .onChange(of: stateTapToRevealEnabled) { _, enabled in
                        stateTapToRevealEnabled = enabled
                    }

                    Toggle(isOn: $statePreviousTokenEnabled, label: {
                        Text("Show previous token")
                    })
                    .onChange(of: statePreviousTokenEnabled) { _, enabled in
                        statePreviousTokenEnabled = enabled
                    }
                }

                Section {
                    Button {
                        loginStatus.loggedIn = false
                        stateService.clearMasterKey()
                    } label: {
                        Text("Lock")
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                    }
                }

                Section {
                    Button {
                        showLogoutConfirmation = true
                    } label: {
                        Text("Log Out")
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "NA"
                        Text("Chronos Authenticator Version \(appVersion) (\(buildVersion))")
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listSectionSpacing(8)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Log Out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log out & Remove Local Data", role: .destructive, action: {
                    swiftDataService.deleteLocallyPersistedChronosData()
                    secureEnclaveService.reset()
                    stateService.resetAllStates()
                })

                Button("Cancel", role: .cancel, action: {
                    self.showLogoutConfirmation = false
                })
            } message: {
                Text("Logging out will remove all local data from this device. Ensure you have a backup before proceeding. Data synced to iCloud will remain accessible.")
            }
        }
    }
}
