import Factory
import SwiftUI

struct TagUpdateView: View {
    @Environment(\.dismiss) var dismiss

    private let stateService = Container.shared.stateService()
    private let cryptoService = Container.shared.cryptoService()
    private let tagService = Container.shared.tagService()

    @State private var newTag: String = ""
    @State private var verified: Bool = false
    @State private var showTokenAdditionSheet: Bool = false

    var tokenPairs: [TokenPair]
    @State var selectedTag: String

    @State var initialTokenPairs: [TokenPair] = []
    @State var selectedTokenPairs: [TokenPair] = []

    var body: some View {
        VStack {
            TagCreationUpdateForm(newTag: $newTag, showTokenAdditionSheet: $showTokenAdditionSheet, selectedTokenPair: $selectedTokenPairs)
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

            let toAdd = selectedTokenPairs.filter { item in
                !initialTokenPairs.contains(where: { $0.id == item.id })
            }
            for tokenPair in toAdd {
                tokenPair.token.tags?.insert(selectedTag)
                cryptoService.updateEncryptedToken(encryptedToken: tokenPair.encToken, token: tokenPair.token)
            }

            stateService.tags.remove(selectedTag)
            if !selectedTokenPairs.isEmpty {
                stateService.tags.insert(newTag)
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
