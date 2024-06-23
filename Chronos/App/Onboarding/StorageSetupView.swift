import CloudKitSyncMonitor
import Factory
import SwiftData
import SwiftUI

struct StorageSetupView: View {
    @Query var vaults: [Vault]

    @State private var iCloudBtnPressed: Bool = false
    @State private var showICloudOverwriteConfirmation: Bool = false
    @State private var showNoBackupWarning: Bool = false
    @State private var showIcloudVaultDeletionWarning: Bool = false
    @State private var nextBtnPressed: Bool = false
    @State private var restoreBtnPressed: Bool = false
    @State private var showICloudUnavailableDialog: Bool = false

    @ObservedObject var syncMonitor = SyncMonitor.shared

    @FocusState private var focusedField: FocusedField?

    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false
    @AppStorage(StateEnum.ICLOUD_SYNC_LAST_ATTEMPT.rawValue) var iCloudSyncLastAttempt: TimeInterval = 0

    let swiftDataService = Container.shared.swiftDataService()

    var body: some View {
        VStack {
            Image(systemName: "icloud")
                .font(.system(size: 44))
                .padding(.bottom, 24)

            Text("Secure your data by storing a fully encrypted backup on Apple iCloud. This encrypted backup will be synchronized across all devices linked to the same Apple account.")
                .multilineTextAlignment(.center)

            Spacer()

            if iCloudSyncLastAttempt == 0 {
                Button {} label: {
                    ProgressView()
                        .tint(Color(red: 0.04, green: 0, blue: 0.11))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .padding(.top, 64)
                .buttonStyle(.borderedProminent)
            } else {
                if syncMonitor.syncStateSummary.isBroken || syncMonitor.syncStateSummary == .accountNotAvailable || syncMonitor.syncStateSummary == .noNetwork {
                    Button(action: {
                        showICloudUnavailableDialog = true
                    }) {
                        Text("iCloud Unavailable")
                            .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 32)
                    }
                    .padding(.top, 64)
                    .buttonStyle(.borderedProminent)
                    .opacity(0.6)
                    .confirmationDialog("iCloud Unavailable", isPresented: $showICloudUnavailableDialog, titleVisibility: .visible) {} message: {
                        Text("Unable to access iCloud due to the following error: \(syncMonitor.syncStateSummary.description)")
                    }
                } else {
                    Button {
                        if swiftDataService.doesICloudBackupExist() {
                            showICloudOverwriteConfirmation = true
                        } else {
                            isICloudEnabled = true
                            nextBtnPressed = true
                        }
                    } label: {
                        Text("Enable iCloud")
                            .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 32)
                    }
                    .padding(.top, 64)
                    .buttonStyle(.borderedProminent)
                    .confirmationDialog("Vault Exists", isPresented: $showICloudOverwriteConfirmation, titleVisibility: .visible) {
                        Button("Restore", action: {
                            restoreBtnPressed = true
                        })

                        Button("Delete & Continue", role: .destructive, action: {
                            showIcloudVaultDeletionWarning = true
                        })

                        Button("Cancel", role: .cancel, action: {
                            self.showICloudOverwriteConfirmation = false
                        })
                    } message: {
                        Text("A vault already exists in iCloud. Would you like to restore your previous vault or delete your existing vault(s)?")
                            .foregroundStyle(.white)
                    }
                    .confirmationDialog("Are you sure?", isPresented: $showIcloudVaultDeletionWarning, titleVisibility: .visible) {
                        Button("Delete & Continue", role: .destructive, action: {
                            Task {
                                swiftDataService.permentalyDeleteAllIcloudData()
                                isICloudEnabled = true
                                nextBtnPressed = true
                            }
                        })

                        Button("Cancel", role: .cancel, action: {
                            self.showIcloudVaultDeletionWarning = false
                        })
                    } message: {
                        Text("All existing data in iCloud will be delete. Are you sure you want to delete all data?")
                    }
                }
            }

            Button {
                showNoBackupWarning = true
            } label: {
                Text("Continue without backups")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)
            .confirmationDialog("Are you sure?", isPresented: $showNoBackupWarning, titleVisibility: .visible) {
                Button("Continue without backups", role: .destructive, action: {
                    isICloudEnabled = false
                    nextBtnPressed = true
                })

                Button("Cancel", role: .cancel, action: {
                    self.showNoBackupWarning = false
                })
            } message: {
                Text("You will not be able to restore your data if no manual backups were made and saved.")
            }
        }
        .padding(.vertical, 32)
        .padding([.horizontal], 24)
        .background(Color(red: 0.04, green: 0, blue: 0.11))
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $nextBtnPressed) {
            if isICloudEnabled {
                PasswordSetupView(vaultName: "My Vault")
            } else {
                PasswordSetupView(vaultName: "My Offline Vault")
            }
        }
        .navigationDestination(isPresented: $restoreBtnPressed) {
            RestoreBackupView()
        }
    }
}
