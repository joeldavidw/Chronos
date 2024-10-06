import Foundation
import SwiftOTP

public class OtpAuthUrlParser {
    static func parseOtpAuthUrl(otpAuthStr: String) throws -> Token {
        guard let otpAuthURL = URL(string: otpAuthStr),
              let components = URLComponents(url: otpAuthURL, resolvingAgainstBaseURL: false),
              let scheme = components.scheme, scheme == "otpauth",
              let host = components.host
        else {
            throw OTPError.invalidURL
        }

        let tokenType = try getTokenType(from: host)
        let token = Token()
        token.type = tokenType

        var path = components.path
        if !path.isEmpty {
            path.remove(at: path.startIndex)
            let labels = path.split(separator: ":", maxSplits: 1).map { String($0) }
            if labels.count == 2 {
                token.issuer = labels[0]
                token.account = labels[1]
            } else if labels.count == 1 {
                path.hasPrefix(":") ? (token.account = labels[0]) : (token.issuer = labels[0])
            }
        }

        guard let queryItems = components.queryItems else { throw OTPError.invalidQueryItem }
        for item in queryItems {
            guard let value = item.value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { continue }
            switch item.name.lowercased() {
            case "secret":
                token.secret = value
            case "issuer":
                token.issuer = value
            case "algorithm":
                guard let algo = TokenAlgorithmEnum(rawValue: value.uppercased()) else {
                    throw OTPError.invalidAlgorithm(value)
                }
                token.algorithm = algo
            case "digits":
                token.digits = Int(value) ?? 6
            case "counter":
                token.counter = Int(value) ?? 0
            case "period":
                token.period = Int(value) ?? 30
            default:
                break
            }
        }

        do {
            try TokenValidator.validate(token: token)
        }

        return token
    }

    private static func getTokenType(from host: String) throws -> TokenTypeEnum {
        switch host.lowercased() {
        case "totp":
            return .TOTP
        case "hotp":
            return .HOTP
        default:
            throw OTPError.invalidType
        }
    }
}
