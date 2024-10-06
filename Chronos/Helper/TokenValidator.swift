import Foundation
import SwiftOTP

public enum OTPError: LocalizedError {
    case invalidURL
    case invalidType
    case invalidQueryItem
    case invalidSecret(String)
    case invalidAlgorithm(String)
    case invalidDigits(Int)
    case invalidCounter(Int)
    case invalidPeriod(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid."
        case .invalidType:
            return "The token type is unsupported."
        case .invalidQueryItem:
            return "The query item in the URL is invalid."
        case let .invalidSecret(reason):
            return "Invalid secret: \(reason)."
        case let .invalidAlgorithm(reason):
            return "Invalid algorithm: \(reason)."
        case let .invalidDigits(digits):
            return "Invalid number of digits: \(digits). Must be between 6 and 8."
        case let .invalidCounter(counter):
            return "Invalid counter value: \(counter)."
        case let .invalidPeriod(period):
            return "Invalid period value: \(period)."
        }
    }
}

public class TokenValidator {
    static func validate(token: Token) throws {
        // Validate Secret
        guard !token.secret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OTPError.invalidSecret("Secret cannot be empty.")
        }

        guard let _ = base32DecodeToData(token.secret) else {
            throw OTPError.invalidSecret("Secret is not base32 encoded.")
        }

        // Validate Algorithm
        guard let _ = TokenAlgorithmEnum(rawValue: token.algorithm.rawValue) else {
            throw OTPError.invalidAlgorithm("The provided algorithm is not valid.")
        }

        // Validate Digits
        guard (6 ... 8).contains(token.digits) else {
            throw OTPError.invalidDigits(token.digits)
        }

        // Validate Counter (specific to HOTP)
        if token.type == .HOTP {
            guard token.counter >= 0 else {
                throw OTPError.invalidCounter(token.counter)
            }
        }

        // Validate Period (specific to TOTP)
        if token.type == .TOTP {
            guard token.period > 0 else {
                throw OTPError.invalidPeriod(token.period)
            }
        }
    }
}
