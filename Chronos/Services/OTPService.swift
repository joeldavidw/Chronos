import Factory
import Foundation
import SwiftOTP

public enum OTPError: Error {
    case invalidURL
    case unsupportedTokenType
    case invalidQueryItem
    case invalidSecret
}

public class OTPService {
    func generateTOTP(token: Token) -> String {
        let digits = token.digits
        let secret = base32DecodeToData(token.secret)!
        let period = token.period
        var algorithm = OTPAlgorithm.sha1

        switch token.algorithm {
        case TokenAlgorithmEnum.SHA1:
            algorithm = OTPAlgorithm.sha1
        case TokenAlgorithmEnum.SHA256:
            algorithm = OTPAlgorithm.sha256
        case TokenAlgorithmEnum.SHA512:
            algorithm = OTPAlgorithm.sha512
        }

        let totp = TOTP(secret: secret, digits: digits, timeInterval: period, algorithm: algorithm)

        return totp!.generate(time: Date()) ?? ""
    }

    func generateHOTP(token: Token) -> String {
        let digits = token.digits
        let secret = base32DecodeToData(token.secret)!
        let counter = token.counter
        let algorithm = OTPAlgorithm.sha1

        let hotp = HOTP(secret: secret, digits: digits, algorithm: algorithm)

        return hotp!.generate(counter: UInt64(counter)) ?? ""
    }

    func parseOtpAuthUrl(otpAuthStr: String) throws -> Token {
        guard let otpAuthURL = URL(string: otpAuthStr),
              let components = URLComponents(url: otpAuthURL, resolvingAgainstBaseURL: false),
              let scheme = components.scheme, scheme == "otpauth",
              let host = components.host
        else {
            throw OTPError.invalidURL
        }

        var path = components.path

        let tokenType = try getTokenType(from: host)
        var token = Token()
        token.type = tokenType

        if !path.isEmpty {
            path.remove(at: path.startIndex)
            token.account = path
        }

        try updateToken(&token, with: components.queryItems)

        return token
    }

    func generateOtpAuthUrl(token: Token) -> URL? {
        var components = URLComponents()
        components.scheme = "otpauth"
        components.host = token.type.rawValue
        components.path = "/\(token.account)"

        var queryItems = [
            URLQueryItem(name: "secret", value: token.secret),
            URLQueryItem(name: "issuer", value: token.issuer),
            URLQueryItem(name: "algorithm", value: token.algorithm.rawValue),
            URLQueryItem(name: "digits", value: "\(token.digits)"),
        ]

        if token.type == .TOTP {
            queryItems.append(URLQueryItem(name: "period", value: "\(token.period)"))
        }

        if token.type == .HOTP {
            queryItems.append(URLQueryItem(name: "counter", value: "\(token.counter)"))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            return nil
        }

        return url
    }

    private func getTokenType(from host: String) throws -> TokenTypeEnum {
        switch host.lowercased() {
        case "totp":
            return .TOTP
        case "hotp":
            return .HOTP
        default:
            throw OTPError.unsupportedTokenType
        }
    }

    private func updateToken(_ token: inout Token, with queryItems: [URLQueryItem]?) throws {
        guard let queryItems = queryItems else { throw OTPError.invalidQueryItem }

        for item in queryItems {
            switch item.name.lowercased() {
            case "secret":
                guard let secret = item.value?.trimmingCharacters(in: .whitespacesAndNewlines), secret.count > 0, base32DecodeToData(secret) != nil else {
                    throw OTPError.invalidSecret
                }
                token.secret = secret
            case "issuer":
                token.issuer = item.value ?? ""
            case "algorithm":
                token.algorithm = TokenAlgorithmEnum(rawValue: item.value?.lowercased() ?? "") ?? .SHA1
            case "digits":
                token.digits = Int(item.value ?? "") ?? 6
            case "counter":
                token.counter = Int(item.value ?? "") ?? 0
            case "period":
                token.period = Int(item.value ?? "") ?? 30
            default:
                break
            }
        }
    }
}
