import Factory
import SwiftUI

struct ExportSelectionView: View {
    let exportService = Container.shared.exportService()

    @State private var showPlainTextExportConfirmation: Bool = false
    @State private var showPlainTextExportSheet: Bool = false
    @State private var encryptedBackupBtnPressed: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 44))
                    .padding(.bottom, 16)

                Text("A backup contains all your token data for this vault. Back up your vault regularly and keep it in a secure location to prevent any data loss.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    encryptedBackupBtnPressed = true
                } label: {
                    Text("Encrypted Zip Archive")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)
                .navigationDestination(isPresented: $encryptedBackupBtnPressed) {
                    EncryptedExportPasswordView()
                }

                Button {
                    showPlainTextExportConfirmation = true
                } label: {
                    Text("Plaintext")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderless)
                .padding(.top, 4)
                .confirmationDialog("Confirm Export", isPresented: $showPlainTextExportConfirmation, titleVisibility: .visible) {
                    Button("Confirm", role: .destructive, action: {
                        showPlainTextExportConfirmation = false
                        showPlainTextExportSheet = true
                    })

                    Button("Cancel", role: .cancel, action: {
                        showPlainTextExportConfirmation = false
                        showPlainTextExportSheet = false
                    })
                } message: {
                    Text("This export contains your token data in an unencrypted format. This file should not be stored or sent over unsecured channels.")
                }
                .sheet(isPresented: $showPlainTextExportSheet) {
                    if let fileurl = exportService.exportHtml() {
                        ActivityView(fileUrl: fileurl)
                            .presentationDetents([.medium, .large])
                            .onDisappear {
                                exportService.cleanupTemporaryDirectory()
                            }
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

                Button {
                    if let fileurl = exportService.exportHtml() {
                        ActivityView(fileUrl: fileurl)
                            .presentationDetents([.medium, .large])
                            .onDisappear {
                                exportService.cleanupTemporaryDirectory()
                            }
                    }
                } label: {
                    Text("HTML")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderless)
                .padding(.top, 4)
            }
            .navigationTitle("Export Selection")
            .padding([.horizontal], 24)
            .padding([.bottom], 32)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
