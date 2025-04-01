import Factory
import SwiftUI

struct TagUpdateView: View {
    @Environment(\.dismiss) var dismiss

    private let cryptoService = Container.shared.cryptoService()
    private let tagService = Container.shared.tagService()

    @State private var newTag: String = ""
    @State private var verified: Bool = false
    @State private var showTokenAdditionSheet: Bool = false

    var tokenPairs: [TokenPair]
    @State var selectedTag: String

    @State private var initialTokenPairs: [TokenPair] = []
    @State private var selectedTokenPairs: [TokenPair] = []

    var body: some View {
        VStack {
            TagCreationUpdateForm(newTag: $newTag, showTokenAdditionSheet: $showTokenAdditionSheet, selectedTokenPairs: $selectedTokenPairs)
        }
        .onAppear {
            newTag = selectedTag
            initialTokenPairs = tokenPairs.filter { ($0.token.tags ?? []).contains(selectedTag) }
            selectedTokenPairs = tokenPairs.filter { ($0.token.tags ?? []).contains(selectedTag) }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Update \"\(selectedTag)\" Tag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(selectedTokenPairs.isEmpty ? "Delete" : "Done") {
            let toRemove = initialTokenPairs.filter { item in
                !selectedTokenPairs.contains(where: { $0.id == item.id })
            }
            for tokenPair in toRemove {
                tokenPair.token.tags?.remove(selectedTag)
                cryptoService.updateEncryptedToken(encryptedToken: tokenPair.encToken, token: tokenPair.token)
            }

            for tokenPair in selectedTokenPairs {
                tokenPair.token.tags?.remove(selectedTag)
                tokenPair.token.tags?.insert(newTag)
                cryptoService.updateEncryptedToken(encryptedToken: tokenPair.encToken, token: tokenPair.token)
            }

            dismiss()
        }
        .disabled(!isValid))
        .sheet(isPresented: $showTokenAdditionSheet) {
            NavigationStack {
                TagTokenSelectionView(tokenPairs: tokenPairs, selectedTokenPair: $selectedTokenPairs)
            }
        }
    }

    var isValid: Bool {
        return tagService.validateTag(newTag) || selectedTag == newTag
    }
}
