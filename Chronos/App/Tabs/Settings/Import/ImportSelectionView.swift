import SwiftUI

struct ImportSource: Identifiable {
    var id: String
    var name: String
    var desc: String
}

struct ImportSelectionView: View {
    let importSources: [ImportSource] = [
        ImportSource(id: "chronos", name: "Chronos", desc: "Export your tokens from Chronos to an unencrypted JSON file, then select the file below."),
//        ImportSource(id: "raivo", name: "Raivo", desc: "Export your tokens from Raivo using \"Export OTPs to ZIP archive\" option. Extract the JSON file from the archive, then select the file below."),
    ]
    
    @EnvironmentObject var importNav: ExportNavigation

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 44))
                    .padding(.bottom, 16)

                List(importSources) { importSource in
                    NavigationLink {
                        SourceSelectedView(importSource: importSource)
                    } label: {
                        Text(importSource.name)
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Import Tokens")
            .padding([.horizontal], 4)
            .padding([.bottom], 32)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel", action: {
                importNav.showSheet = false
            }))
        }
    }
}
