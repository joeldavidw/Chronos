import Factory
import SwiftUI

struct TagManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var refreshID = UUID()

    private let stateService = Container.shared.stateService()

    var tokenPairs: [TokenPair]

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
            .id(refreshID)
        }
        .onAppear {
            refreshID = UUID()
        }
        .background(Color(.systemGray6))
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}
