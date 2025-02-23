import Factory
import SwiftUI

struct TagUpdateView: View {
    @Environment(\.dismiss) var dismiss

    private let stateService = Container.shared.stateService()
    private let cryptoService = Container.shared.cryptoService()

    @State private var newTag: String = ""
    @State private var verified: Bool = false
    @State private var showTokenAdditionSheet: Bool = false

    var tokenPairs: [TokenPair]
    @State var selectedTag: String

    @State var selectedTokenPair: [TokenPair] = []
    @State var originalTokenPair: [TokenPair] = []

    var body: some View {
        VStack {
            TagCreationUpdateForm(newTag: $newTag, showTokenAdditionSheet: $showTokenAdditionSheet, selectedTokenPair: $selectedTokenPair)
        }
        .onAppear {
            newTag = selectedTag
            originalTokenPair = tokenPairs.filter { ($0.token.tags ?? []).contains(selectedTag) }
            selectedTokenPair = tokenPairs.filter { ($0.token.tags ?? []).contains(selectedTag) }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Update \"\(selectedTag)\" Tag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(selectedTokenPair.isEmpty ? "Delete" : "Done") {
            for tokenPair in tokenPairs {
                tokenPair.token.tags?.remove(selectedTag)

                if selectedTokenPair.contains(where: { $0.id == tokenPair.id }) {
                    tokenPair.token.tags?.insert(newTag)
                }

                cryptoService.updateEncryptedToken(encryptedToken: tokenPair.encToken, token: tokenPair.token)
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
        let tempTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let isNotEmpty = !tempTag.isEmpty
        let isUnique = !stateService.tags.map { $0.lowercased() }.contains(tempTag) || (newTag == selectedTag)
        let hasValidCharacters = tempTag.range(of: "^[\\p{L}0-9_\\s\\p{P}\\p{S}]+$", options: .regularExpression) != nil

        return isNotEmpty && isUnique && hasValidCharacters
    }
}
