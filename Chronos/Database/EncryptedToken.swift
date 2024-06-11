import Foundation
import SwiftData

@Model
class EncryptedToken {
    var encryptedTokenCiper: [UInt8]?
    var iv: [UInt8]?
    var authenticationTag: [UInt8]?
    var createdAt: Date?

    init(encryptedTokenCiper: [UInt8], iv: [UInt8], authenticationTag: [UInt8], createdAt: Date) {
        self.encryptedTokenCiper = encryptedTokenCiper
        self.iv = iv
        self.authenticationTag = authenticationTag
        self.createdAt = createdAt
    }
}
