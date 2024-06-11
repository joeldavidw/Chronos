import SwiftData

struct KeyParams: Codable {
    var iv: [UInt8]
    var tag: [UInt8]
}

struct PasswordParams: Codable {
    var salt: String
}

enum KdfEnum: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case SCRYPT
}

struct KdfParams: Codable {
    var type: KdfEnum
    var n: Int
    var r: Int
    var p: Int
}

@Model
class ChronosCrypto {
    var key: [UInt8]?
    var keyParams: KeyParams?
    var passwordParams: PasswordParams?
    var kdfParams: KdfParams?

    init(key: [UInt8], keyParams: KeyParams, passwordParams: PasswordParams, kdfParams: KdfParams) {
        self.key = key
        self.keyParams = keyParams
        self.passwordParams = passwordParams
        self.kdfParams = kdfParams
    }
}
