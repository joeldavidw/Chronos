import Factory
import SwiftUI

struct ImportDetailView: View {
    @State var importSource: ImportSource

    @State private var showFileImporter = false
    @State private var showImportConfirmation = false
    @State private var tokens: [Token]?

    @EnvironmentObject private var importNav: ExportNavigation

    private let importService = Container.shared.importService()

    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text(importSource.desc)
                .multilineTextAlignment(.center)

            Spacer()

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
            .sheet(isPresented: $showImportConfirmation) {
                NavigationStack {
                    if let tokens = tokens {
                        ImportConfirmationView(tokens: tokens)
                    } else {
                        ImportFailureView()
                    }
                }
            }

            Button(action: { importNav.showSheet = false }) {
                Text("Cancel")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .navigationTitle("Import from \(importSource.name)")
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case let .success(fileUrls):
            if let fileUrl = fileUrls.first {
                tokens = importService.importTokens(importSource: importSource, url: fileUrl)
                showImportConfirmation = true
            }
        case let .failure(error):
            print(error)
        }
    }
}
