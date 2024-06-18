import Foundation
import SwiftData

@Model
class Vault {
    var vaultId: UUID?
    var createdAt: Date?
    var name: String = "My Vault"

    @Relationship(deleteRule: .cascade)
    var chronosCryptos: [ChronosCrypto]? = []

    @Relationship(deleteRule: .cascade)
    var encryptedTokens: [EncryptedToken]? = []

    init(vaultId: UUID, name: String, createdAt: Date) {
        self.vaultId = vaultId
        self.name = name
        self.createdAt = createdAt
    }
}
