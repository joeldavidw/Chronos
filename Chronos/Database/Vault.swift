import Foundation
import SwiftData

@Model
class Vault {
    var vaultId: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \ChronosCrypto.vault)
    var chronosCryptos: [ChronosCrypto]?
    
    @Relationship(deleteRule: .cascade, inverse: \EncryptedToken.vault)
    var encryptedTokens: [EncryptedToken]?
    
    init(vaultId: UUID? = nil, chronosCryptos: [ChronosCrypto]? = nil, encryptedTokens: [EncryptedToken]? = nil) {
        self.vaultId = vaultId
        self.chronosCryptos = chronosCryptos
        self.encryptedTokens = encryptedTokens
    }
}
