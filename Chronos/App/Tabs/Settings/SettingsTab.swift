import CloudKitSyncMonitor
import Factory
import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject private var loginStatus: LoginStatus
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) private var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) private var isICloudEnabled: Bool = false
    @AppStorage(StateEnum.ICLOUD_SYNC_LAST_ATTEMPT.rawValue) private var iCloudSyncLastAttempt: TimeInterval = 0

    private let secureEnclaveService = Container.shared.secureEnclaveService()
    private let swiftDataService = Container.shared.swiftDataService()
    private let stateService = Container.shared.stateService()
    private let exportService = Container.shared.exportService()

    @State private var showExportJsonConfirmation: Bool = false
    @State private var showExportJsonSheet: Bool = false

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
                        Text(lastSyncedText)
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
                        showExportJsonConfirmation = true
                    } label: {
                        Text("Export")
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .confirmationDialog("Confirm Export", isPresented: $showExportJsonConfirmation, titleVisibility: .visible) {
                        Button("Confirm", role: .destructive, action: {
                            self.showExportJsonConfirmation = false
                            self.showExportJsonSheet = true
                        })

                        Button("Cancel", role: .cancel, action: {
                            self.showExportJsonConfirmation = false
                            self.showExportJsonSheet = false
                        })
                    } message: {
                        Text("This export contains your token data in an unencrypted format. This file should not be stored or sent over unsecured channels.")
                    }
                    .sheet(isPresented: $showExportJsonSheet) {
                        if let fileurl = exportService.exportToUnencryptedJson() {
                            ActivityView(fileUrl: fileurl)
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(Visibility.hidden)
                        } else {
                            VStack {
                                Image(systemName: "xmark.circle")
                                    .fontWeight(.light)
                                    .font(.system(size: 64))
                                    .padding(.bottom, 8)
                                Text("An error occurred while during the export process")
                            }
                        }
                    }
                    .onChange(of: scenePhase) { _, newValue in
                        if newValue != .active {
                            self.showExportJsonConfirmation = false
                            self.showExportJsonSheet = false
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
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
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

struct ActivityView: UIViewControllerRepresentable {
    let fileUrl: URL

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
