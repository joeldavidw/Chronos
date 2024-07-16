import Factory
import SwiftUI

struct SourceSelectedView: View {
    @State var importSource: ImportSource
    @State var showFileImporter: Bool = false

    let importService = Container.shared.importService()

    var body: some View {
        VStack {
            HStack {
                Image("Chronos")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(64 * 0.225)

                Image(systemName: "arrowshape.right.fill")
                    .font(.system(size: 24))
                    .padding(.horizontal, 8)

                Image("Chronos")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(64 * 0.225)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)

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
                    importService.importFromChronos(url: fileUrl!)

                case let .failure(error):
                    print(error)
                }

            })
        }
        .padding([.horizontal], 24)
        .padding([.bottom], 32)
        .navigationTitle("Import from \(importSource.name)")
    }
}
