import Factory
import SwiftUI

struct TagCreationView: View {
    @Environment(\.dismiss) var dismiss

    private let stateService = Container.shared.stateService()
    private let cryptoService = Container.shared.cryptoService()

    @State private var newTag: String = ""
    @State private var verified: Bool = false
    @State private var showTokenAdditionSheet: Bool = false

    var tokenPairs: [TokenPair]
    @State var selectedTokenPair: [TokenPair] = []

    var body: some View {
        VStack {
            TagCreationUpdateForm(newTag: $newTag, showTokenAdditionSheet: $showTokenAdditionSheet, selectedTokenPair: $selectedTokenPair)
        }
        .background(Color(.systemGray6))
        .navigationTitle("New Tag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done", action: {
            for tokenPair in selectedTokenPair {
                let updatedTokenPair = tokenPair
                updatedTokenPair.token.tags?.insert(newTag)

                cryptoService.updateEncryptedToken(encryptedToken: tokenPair.encToken, token: updatedTokenPair.token)
            }

            if selectedTokenPair.count > 0 {
                stateService.tags.insert(newTag)
            }

            dismiss()
        })
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
        let isUnique = !stateService.tags.map { $0.lowercased() }.contains(tempTag)
        let hasValidCharacters = tempTag.range(of: "^[\\p{L}0-9_\\s\\p{P}\\p{S}]+$", options: .regularExpression) != nil

        return isNotEmpty && isUnique && hasValidCharacters && !selectedTokenPair.isEmpty
    }
}
