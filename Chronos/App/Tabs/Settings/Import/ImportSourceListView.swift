import SwiftUI

enum ImportSourceId {
    case CHRONOS
    case AEGIS
    case RAIVO
    case GOOGLE_AUTHENTICATOR
    case LASTPASS
}

enum ImportType {
    case JSON
    case IMAGE
}

struct ImportSource: Identifiable {
    var id: ImportSourceId
    var name: String
    var desc: String
    var importType: ImportType
}

struct ImportSourceListView: View {
    let importSources: [ImportSource] = [
        ImportSource(id: .CHRONOS, name: "Chronos", desc: "Export your tokens from Chronos to an unencrypted JSON file, then select the file below.", importType: .JSON),
        ImportSource(id: .AEGIS, name: "Aegis", desc: "Export your tokens from Aegis using \"Export\" option. Select \"JSON\" as the export format and unselect \"Encrypt the vault\", then select the file below.", importType: .JSON),
        ImportSource(id: .RAIVO, name: "Raivo", desc: "Export your tokens from Raivo using \"Export OTPs to ZIP archive\" option. Extract the JSON file from the archive, then select the file below.", importType: .JSON),
        ImportSource(id: .GOOGLE_AUTHENTICATOR, name: "Google Authenticator", desc: "Export your tokens from Google Authenticator using the \"Transfer accounts\" option. Scan the QR code.", importType: .IMAGE),
        ImportSource(id: .LASTPASS, name: "LastPass Authenticator", desc: "Export your tokens from LastPass Authenticator using the \"Export accounts to file\" option, then select the file below.", importType: .JSON),
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
                        ImportSourceDetailView(importSource: importSource)
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
