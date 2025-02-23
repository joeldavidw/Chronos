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

    @State var selectedTokenPair: [TokenPair] = []

    var body: some View {
        VStack {
            TagCreationUpdateForm(newTag: $newTag, showTokenAdditionSheet: $showTokenAdditionSheet, selectedTokenPair: $selectedTokenPair)
        }
        .onAppear {
            newTag = selectedTag
            selectedTokenPair = tokenPairs.filter { ($0.token.tags ?? []).contains(selectedTag) }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Update \"\(selectedTag)\" Tag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(selectedTokenPair.isEmpty ? "Delete" : "Done") {
            for tokenPair in tokenPairs {
                if tokenPair.token.tags?.contains(selectedTag) ?? false {
                    tokenPair.token.tags?.remove(selectedTag)

                    if selectedTokenPair.contains(where: { $0.id == tokenPair.id }) {
                        tokenPair.token.tags?.insert(newTag)
                    }

                    cryptoService.updateEncryptedToken(encryptedToken: tokenPair.encToken, token: tokenPair.token)
                }
            }

            stateService.tags.remove(selectedTag)
            if !selectedTokenPair.isEmpty {
                stateService.tags.insert(newTag)
            }

            dismiss()
        }
        .disabled(!isValid))
        .sheet(isPresented: $showTokenAdditionSheet) {
            NavigationStack {
                TagTokenSelectionView(tokenPairs: tokenPairs, selectedTokenPair: $selectedTokenPair)
            }
        }
    }

    var isValid: Bool {
        return tagService.validateTag(newTag) || selectedTag == newTag
    }
}
