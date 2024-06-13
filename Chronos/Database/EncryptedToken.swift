import Foundation
import SwiftData

@Model
class EncryptedToken {
    var vault: Vault?
    
    var encryptedTokenCiper: [UInt8]?
    var iv: [UInt8]?
    var authenticationTag: [UInt8]?
    var createdAt: Date?

    init(vault: Vault, encryptedTokenCiper: [UInt8]? = nil, iv: [UInt8]? = nil, authenticationTag: [UInt8]? = nil, createdAt: Date? = nil) {
        self.vault = vault
        self.encryptedTokenCiper = encryptedTokenCiper
        self.iv = iv
        self.authenticationTag = authenticationTag
        self.createdAt = createdAt
    }
}
