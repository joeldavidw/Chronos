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

    var isValid: Bool {
        return validationError == nil
    }

    var validationError: Error? {
        do {
            try TokenValidator.validate(token: self)
            return nil
        } catch {
            return error
        }
    }

    func generateOtp(previous: Bool? = false) -> String {
        switch type {
        case .TOTP:
            return generateTOTP(previous: previous)
        case .HOTP:
            return generateHOTP()
        }
    }

    private func generateTOTP(previous: Bool? = false) -> String {
        let digits = digits
        let secret = base32DecodeToData(secret)!
        let period = period

        var otpAlgo = OTPAlgorithm.sha1
        switch algorithm {
        case TokenAlgorithmEnum.SHA1:
            otpAlgo = OTPAlgorithm.sha1
        case TokenAlgorithmEnum.SHA256:
            otpAlgo = OTPAlgorithm.sha256
        case TokenAlgorithmEnum.SHA512:
            otpAlgo = OTPAlgorithm.sha512
        }

        let totp = TOTP(secret: secret, digits: digits, timeInterval: period, algorithm: otpAlgo)

        var time = Date()
        if let previous {
            time = previous ? time.addingTimeInterval(-Double(period)) : time
        }

        return totp!.generate(time: time) ?? ""
    }

    private func generateHOTP() -> String {
        let digits = digits
        let secret = base32DecodeToData(secret)!
        let counter = counter
        let algorithm = OTPAlgorithm.sha1

        let hotp = HOTP(secret: secret, digits: digits, algorithm: algorithm)

        return hotp!.generate(counter: UInt64(counter)) ?? ""
    }

    func otpAuthUrl() -> String? {
        var components = URLComponents()
        components.scheme = "otpauth"
        components.host = type.rawValue.lowercased()

        components.path = !account.isEmpty
            ? (!issuer.isEmpty ? "/\(issuer):\(account)" : "/\(account)")
            : "/"

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "secret", value: secret),
            URLQueryItem(name: "algorithm", value: algorithm.rawValue),
            URLQueryItem(name: "digits", value: "\(digits)"),
        ]

        if !issuer.isEmpty {
            queryItems.append(URLQueryItem(name: "issuer", value: issuer))
        }

        switch type {
        case .TOTP:
            queryItems.append(URLQueryItem(name: "period", value: "\(period)"))
        case .HOTP:
            queryItems.append(URLQueryItem(name: "counter", value: "\(counter)"))
        }

        components.queryItems = queryItems

        return components.string
    }
}
