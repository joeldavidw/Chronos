import CloudKitSyncMonitor
import Factory
import SwiftData
import SwiftUI

struct WelcomeView: View {
    let swiftDataService = Container.shared.swiftDataService()
    let stateService = Container.shared.stateService()

    @Query var vaults: [Vault]

    @ObservedObject var syncMonitor = SyncMonitor.shared

    @State private var getStartedPressed: Bool = false
    @State private var restorePressed: Bool = false

    @State private var hasSynced: Bool = false
    @State private var syncTimer: Timer?
    @State private var showICloudUnavailableDialog: Bool = false

    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false
    @AppStorage(StateEnum.ICLOUD_SYNC_LAST_ATTEMPT.rawValue) var iCloudSyncLastAttempt: TimeInterval = 0

    var body: some View {
        NavigationStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .padding(.bottom, 8)

                Button {
                    getStartedPressed = true
                } label: {
                    Text("Get started")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)

                Group {
                    if syncMonitor.syncStateSummary.isBroken || syncMonitor.syncStateSummary == .accountNotAvailable || syncMonitor.syncStateSummary == .noNetwork {
                        Button(action: {
                            showICloudUnavailableDialog = true
                        }) {
                            Text("iCloud Unavailable")
                                .bold()
                        }
                        .buttonStyle(.borderless)
                        .opacity(0.4)
                        .confirmationDialog("iCloud Unavailable", isPresented: $showICloudUnavailableDialog, titleVisibility: .visible) {} message: {
                            Text("Unable to access iCloud due to the following error: \(syncMonitor.syncStateSummary.description)")
                        }
                    } else {
                        if hasSynced {
                            Button(action: {
                                if vaults.count == 1 {
                                    stateService.setVaultId(vaultId: vaults.first!.vaultId!)
                                }

                                restorePressed = true
                            }) {
                                Text("Restore from iCloud")
                                    .bold()
                            }
                            .disabled(vaults.isEmpty)
                            .buttonStyle(.borderless)
                        } else {
                            ProgressView()
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 32)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .padding([.horizontal], 24)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $getStartedPressed) {
                StorageSetupView()
            }
            .navigationDestination(isPresented: $restorePressed) {
                if vaults.count == 1 {
                    RestoreBackupView()
                } else if vaults.count > 1 {
                    VaultSelectionView()
                }
            }
        }
        .onAppear(perform: {
            swiftDataService.resetModelContainers()
            iCloudSyncLastAttempt = 0

            if syncMonitor.syncStateSummary == .succeeded {
                syncTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                    hasSynced = true
                }
            }
        })
        .onChange(of: syncMonitor.syncStateSummary) { _, newValue in
            syncTimer?.invalidate()

            if newValue == .succeeded {
                syncTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                    hasSynced = true
                    iCloudSyncLastAttempt = Date().timeIntervalSince1970
                }
            }
        }
    }
}
