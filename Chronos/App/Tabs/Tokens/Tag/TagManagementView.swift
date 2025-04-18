import Factory
import SwiftData
import SwiftUI

struct TagManagementView: View {
    @Query private var vaults: [Vault]

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var loginStatus: LoginStatus

    @State private var tokenPairs: [TokenPair] = []
    @State private var tags: Set<String> = []

    private let stateService = Container.shared.stateService()
    private let cryptoService = Container.shared.cryptoService()

    private var encryptedTokens: [EncryptedToken] {
        if !loginStatus.loggedIn {
            return []
        }

        guard let vaultId = stateService.getVaultId(),
              let vault = vaults.first(where: { $0.vaultId == vaultId })
        else {
            return []
        }

        return vault.encryptedTokens ?? []
    }

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

                ForEach(Array(tags).sorted(), id: \.self) { tag in
                    NavigationLink {
                        TagUpdateView(tokenPairs: tokenPairs, selectedTag: tag)
                    } label: {
                        Text(tag)
                    }
                }
            }
        }
        .onAppear {
            Task { await updateTokenPairs() }
        }
        .onChange(of: encryptedTokens) { _, _ in
            Task { await updateTokenPairs() }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func updateTokenPairs() async {
        guard loginStatus.loggedIn else {
            tokenPairs = []
            return
        }

        let decryptedPairs: [TokenPair] = encryptedTokens.compactMap { encToken in
            guard let decryptedToken = cryptoService.decryptToken(encryptedToken: encToken) else {
                return nil
            }
            return TokenPair(id: encToken.id, token: decryptedToken, encToken: encToken)
        }

        tags = Set(
            decryptedPairs
                .flatMap { $0.token.tags ?? [] }
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        )

        tokenPairs = decryptedPairs
    }
}
