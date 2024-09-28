import Foundation
import SwiftOTP

enum TokenTypeEnum: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case TOTP
    case HOTP
}

enum TokenAlgorithmEnum: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case SHA1
    case SHA256
    case SHA512
}

class Token: Codable, Identifiable {
    var issuer: String = ""
    var account: String = ""
    var type: TokenTypeEnum = .TOTP

    var secret: String = ""
    var algorithm: TokenAlgorithmEnum = .SHA1
    var digits: Int = 6

    // TOTP
    var period: Int = 30

    // HOTP
    var counter: Int = 0

    // Extra Data
    var pinned: Bool? = false
}

func validateToken(
    token: Token
) -> (isValid: Bool, errorMessage: String?) {
    if token.account.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return (false, "Invalid account")
    }

    if token.secret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return (false, "Invalid secret - empty")
    }

    if base32DecodeToData(token.secret) == nil {
        return (false, "Invalid secret - not base32 encoded")
    }

//    // Validate algorithm
//    guard let algorithm = TokenAlgorithmEnum(rawValue: algorithmString) else {
//        return (false, "Invalid algorithm")
//    }

    // Validate digits
    guard (6 ... 8).contains(token.digits) else {
        return (false, "Invalid digits")
    }

    // Validate counter
    guard token.counter >= 0 else {
        return (false, "Invalid counter")
    }

    // Validate period
    guard token.period > 0 else {
        return (false, "Invalid period")
    }

    return (true, nil)
}
