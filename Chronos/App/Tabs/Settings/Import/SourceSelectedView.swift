import Factory
import SwiftUI

struct SourceSelectedView: View {
    @State var importSource: ImportSource
    @State var showFileImporter: Bool = false
    @State var showImportConfirmation: Bool = false
    @State var tokens: [Token]?
    
    @EnvironmentObject var importNav: ExportNavigation

    let importService = Container.shared.importService()

    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text(importSource.desc)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                showFileImporter = true
            } label: {
                Text("Select file")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json], allowsMultipleSelection: false, onCompletion: { results in
                switch results {
                case let .success(fileurls):
                    let fileUrl = fileurls.first
                    tokens = importService.importFromChronos(url: fileUrl!)
                    showImportConfirmation = true
                case let .failure(error):
                    print(error)
                }
            })
            
            Button {
                importNav.showSheet = false
            } label: {
                Text("Cancel")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.borderless)
        }
        .padding([.horizontal], 24)
        .padding([.bottom], 32)
        .navigationTitle("Import from \(importSource.name)")
        .sheet(isPresented: $showImportConfirmation, content: {
            NavigationStack {
                ImportConfirmationView(tokens: tokens)
            }
        })
    }
}
