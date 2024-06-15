import Foundation
import SwiftData

@Model
class Vault {
    var vaultId: UUID?
    var createdAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \ChronosCrypto.vault)
    var chronosCryptos: [ChronosCrypto]?

    @Relationship(deleteRule: .cascade, inverse: \EncryptedToken.vault)
    var encryptedTokens: [EncryptedToken]?

    init(vaultId: UUID? = nil, createdAt: Date? = nil, chronosCryptos: [ChronosCrypto]? = nil, encryptedTokens: [EncryptedToken]? = nil) {
        self.vaultId = vaultId
        self.createdAt = createdAt
        self.chronosCryptos = chronosCryptos
        self.encryptedTokens = encryptedTokens
    }
}
