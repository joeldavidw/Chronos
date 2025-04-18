import Factory
import SwiftUI

struct TagCreationUpdateForm: View {
    @Binding var newTag: String
    @Binding var showTokenAdditionSheet: Bool

    @Binding var selectedTokenPairs: [TokenPair]

    var body: some View {
        Form {
            Section("Tag Name") {
                TextField(text: $newTag, prompt: Text("Examples: Personal, Work")) {
                    Text("Examples: Personal, Work")
                }
            }

            Section(header: Text("Included Tokens")) {
                Button {
                    showTokenAdditionSheet = true
                } label: {
                    HStack {
                        Label("Add Token", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                }
                List(selectedTokenPairs, id: \.id) { tokenPair in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(!tokenPair.token.issuer.isEmpty ? tokenPair.token.issuer : tokenPair.token.account)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            if !tokenPair.token.issuer.isEmpty && !tokenPair.token.account.isEmpty {
                                Text("- \(tokenPair.token.account)")
                                    .foregroundStyle(.gray)
                                    .lineLimit(1)
                            }
                        }

                        if let tags = tokenPair.token.tags, !tags.isEmpty {
                            Text(tags.joined(separator: ", "))
                                .foregroundStyle(.gray)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            withAnimation {
                                if let index = selectedTokenPairs.firstIndex(where: { $0.id == tokenPair.id }) {
                                    selectedTokenPairs.remove(at: index)
                                }
                            }
                        } label: {
                            VStack(alignment: .center) {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
}
