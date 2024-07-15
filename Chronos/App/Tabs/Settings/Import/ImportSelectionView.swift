import SwiftUI

struct ImportSource: Identifiable {
    var id: String
    var name: String
}

struct ImportSelectionView: View {
    let importSources: [ImportSource] = [
        ImportSource(id: "chronos", name: "Chronos"),
        ImportSource(id: "google", name: "Google Authenticator"),
        ImportSource(id: "Raivo", name: "Raivo"),
    ]
    
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
                        HStack {
                            Text(importSource.name)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .opacity(0.4)
                        }
                    }
                }
            }
            .navigationTitle("Import Tokens")
            .padding([.horizontal], 4)
            .padding([.bottom], 32)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
