import Factory
import SwiftUI

struct TagManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State var tokenPairs: [TokenPair]
    @State private var refreshID = UUID()

    private let stateService = Container.shared.stateService()
    private let cryptoService = Container.shared.cryptoService()

    var body: some View {
        VStack {
            List {
                NavigationLink {
                    TagCreationView(tokenPairs: tokenPairs)
                } label: {
                    HStack {
                        Label("New Tag", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                            .foregroundColor(.accent)
                    }
                }

                ForEach(Array(stateService.tags), id: \.self) { tag in
                    NavigationLink {
                        TagUpdateView(tokenPairs: tokenPairs, selectedTag: tag)
                    } label: {
                        Text(tag)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}
