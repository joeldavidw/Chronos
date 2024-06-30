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
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 44))
                    .padding(.bottom, 16)

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
                    EncryptedExportView()
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
            }
            .navigationTitle("Export")
            .padding([.horizontal], 24)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationBarTitleDisplayMode(.inline)
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
