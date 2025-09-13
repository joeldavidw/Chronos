import AlertKit
import CodeScanner
import Factory
import SwiftUI

class ImportSourceDetailViewModel: ObservableObject {
    @Published var tokens: [Token]?
    private let importService = Container.shared.importService()

    func importTokensFromFile(importSource: ImportSource, fileUrl: URL) {
        if importSource.importType == .JSON {
            tokens = importService.importTokensViaJsonFile(importSource: importSource, url: fileUrl)
        }

        if importSource.importType == .TEXT {
            tokens = importService.importTokensViaTextFile(importSource: importSource, url: fileUrl)
        }
    }

    func importTokensFromString(importSource: ImportSource, scannedStr: String) {
        tokens = importService.importTokensViaString(importSource: importSource, scannedStr: scannedStr)
    }
}

struct ImportSourceDetailView: View {
    @State var importSource: ImportSource

    @State private var showFileImporter = false
    @State private var showImportConfirmation = false
    @State private var unableToAccessCamera = false

    @EnvironmentObject private var importNav: ExportNavigation

    @StateObject private var viewModel = ImportSourceDetailViewModel()

    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text(importSource.desc)
                .multilineTextAlignment(.center)

            Spacer()

            if importSource.importType == .JSON {
                Button(action: { showFileImporter = true }) {
                    Text("Select file")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [.json],
                    allowsMultipleSelection: false,
                    onCompletion: handleFileImport
                )
            }

            if importSource.importType == .TEXT {
                Button(action: { showFileImporter = true }) {
                    Text("Select file")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [.text],
                    allowsMultipleSelection: false,
                    onCompletion: handleFileImport
                )
            }

            if importSource.importType == .IMAGE {
                if !unableToAccessCamera {
                    CodeScannerView(
                        codeTypes: [.qr],
                        scanMode: .once,
                        scanInterval: 0.1,
                        shouldVibrateOnSuccess: false,
                        completion: handleScan
                    )
                    .frame(height: 200, alignment: .center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .cornerRadius(8)
                } else {
                    VStack {
                        Spacer()
                        Text("Chronos requires camera access to scan 2FA QR codes")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .bold()
                            .padding(.horizontal, 16)
                        Button("Open settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                        .padding(.top, 4)
                        Spacer()
                    }
                    .frame(height: 200, alignment: .center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.black)
                    .cornerRadius(8)
                }
            }

            Button(action: { importNav.showSheet = false }) {
                Text("Cancel")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.borderless)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .navigationTitle("Import from \(importSource.name)")
        .sheet(isPresented: $showImportConfirmation) {
            NavigationStack {
                if let tokens = viewModel.tokens {
                    ImportConfirmationView(tokens: tokens)
                } else {
                    ImportFailureView()
                }
            }
        }
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case let .success(fileUrls):
            if let fileUrl = fileUrls.first {
                viewModel.importTokensFromFile(importSource: importSource, fileUrl: fileUrl)
                showImportConfirmation = true
            }
        case let .failure(error):
            print(error)
        }
    }

    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case let .success(result):
            viewModel.importTokensFromString(importSource: importSource, scannedStr: result.string)
            showImportConfirmation = true
        case .failure:
            DispatchQueue.main.async {
                unableToAccessCamera = true
            }
        }
    }
}
