import Foundation
import SwiftData

@Model
class Vault {
    var vaultId: UUID?
    var createdAt: Date?

    @Relationship(deleteRule: .cascade)
    var chronosCryptos: [ChronosCrypto]? = []

    @Relationship(deleteRule: .cascade)
    var encryptedTokens: [EncryptedToken]? = []

    init(vaultId: UUID, createdAt: Date) {
        self.vaultId = vaultId
        self.createdAt = createdAt
    }
}
