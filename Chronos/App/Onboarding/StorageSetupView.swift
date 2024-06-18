import Factory
import SwiftUI

struct StorageSetupView: View {
    @State private var iCloudBtnPressed: Bool = false
    @State private var showICloudOverwriteConfirmation: Bool = false
    @State private var nextBtnPressed: Bool = false

    @FocusState private var focusedField: FocusedField?

    @AppStorage(StateEnum.ICLOUD_BACKUP_ENABLED.rawValue) var isICloudEnabled: Bool = false

    let swiftDataService = Container.shared.swiftDataService()

    var body: some View {
        VStack {
            Image(systemName: "icloud")
                .font(.system(size: 44))
                .padding(.bottom, 24)

            Text("Secure your data by storing a fully encrypted backup on Apple iCloud. This encrypted backup will be synchronized across all devices linked to the same Apple account.")
                .multilineTextAlignment(.center)

            Spacer()

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

            Button {
                isICloudEnabled = false
                nextBtnPressed = true
            } label: {
                Text("Continue without backup")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 32)
        .padding([.horizontal], 24)
        .background(Color(red: 0.04, green: 0, blue: 0.11))
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $nextBtnPressed) {
            VaultSetupView()
        }
        .confirmationDialog("Vault Exists", isPresented: $showICloudOverwriteConfirmation, titleVisibility: .visible) {
            Button("Continue", role: .destructive, action: {
                isICloudEnabled = true
                nextBtnPressed = true
            })

            Button("Cancel", role: .cancel, action: {
                self.showICloudOverwriteConfirmation = false
            })
        } message: {
            Text("A vault already exists in iCloud. Are you sure you want to create a new one?")
        }
    }
}
