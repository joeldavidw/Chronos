import Factory
import SwiftUI

struct TagTokenSelectionView: View {
    @Environment(\.dismiss) var dismiss

    private let stateService = Container.shared.stateService()

    @State private var verified: Bool = false
    @State private var selectedTokenPairIds: Set<ObjectIdentifier> = []

    var tokenPairs: [TokenPair]
    @Binding var selectedTokenPair: [TokenPair]

    var body: some View {
        VStack {
            List {
                ForEach(tokenPairs, id: \.id) { tokenPair in
                    Button {
                        if selectedTokenPairIds.contains(tokenPair.id) {
                            selectedTokenPairIds.remove(tokenPair.id)
                        } else {
                            selectedTokenPairIds.insert(tokenPair.id)
                        }
                    } label: {
                        HStack {
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
                            Spacer()
                            if selectedTokenPairIds.contains(tokenPair.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }.foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            selectedTokenPairIds = Set(selectedTokenPair.map(\.self).compactMap(\.id))
        }
        .background(Color(.systemGray6))
        .navigationTitle("Include Tokens")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done", action: {
            selectedTokenPair = tokenPairs.filter { selectedTokenPairIds.contains($0.id) }
            dismiss()
        }))
    }
}
