import Factory
import SwiftUI
import LinkPresentation

struct SettingsTab: View {
    @EnvironmentObject var loginStatus: LoginStatus
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false
    
    let secureEnclaveService = Container.shared.secureEnclaveService()
    let swiftDataService = Container.shared.swiftDataService()
    let stateService = Container.shared.stateService()
    let exportService = Container.shared.exportService()
    
    @State private var showExportJsonConfirmation: Bool = false
    @State private var showExportJsonSheet: Bool = false
    
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Storage")) {
                    Toggle(isOn: $isICloudEnabled, label: {
                        Text("iCloud Backup")
                    }).disabled(true)
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
                        ActivityView(fileUrl: exportService.exportToUnencryptedJson())
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(Visibility.hidden)
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
                }
                .listSectionSpacing(8)
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Log Out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log out & Remove Local Data", role: .destructive, action: {
                    swiftDataService.deleteLocalChronosCryptoData()
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
