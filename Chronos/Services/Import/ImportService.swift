import Factory
import Foundation
import Logging
import SwiftyJSON

public class ImportService {
    private let logger = Logger(label: "ImportService")
    private let vaultService = Container.shared.vaultService()

    func importTokensViaFile(importSource: ImportSource, url: URL) -> [Token]? {
        guard let json = readFile(url: url) else {
            logger.error("Failed to read file at \(url)")
            return nil
        }

        switch importSource.id {
        case .CHRONOS:
            return importFromChronos(json: json)
        case .AEGIS:
            return importFromAegis(json: json)
        case .RAIVO:
            return importFromRaivo(json: json)
        case .LASTPASS:
            return importFromLastpass(json: json)
        default:
            return nil
        }
    }

    func importTokensViaString(importSource: ImportSource, scannedStr: String) -> [Token]? {
        switch importSource.id {
        case .GOOGLE_AUTHENTICATOR:
            return importFromGoogleAuth(otpAuthMigration: scannedStr)
        default:
            return nil
        }
    }

    private func readFile(url: URL) -> JSON? {
        guard url.startAccessingSecurityScopedResource() else {
            logger.error("Failed to start accessing security scoped resource for \(url)")
            return nil
        }

        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let jsonData = try String(contentsOf: url, encoding: .utf8)
            return JSON(parseJSON: jsonData)
        } catch {
            logger.error("Error reading file at \(url): \(error.localizedDescription)")
            return nil
        }
    }
}

extension ImportService {
    func importFromChronos(json: JSON) -> [Token]? {
        do {
            let decoder = JSONDecoder()
            let tokens = try decoder.decode([Token].self, from: json["tokens"].rawData())
            return tokens
        } catch {
            logger.error("Error decoding tokens from JSON: \(error.localizedDescription)")
            return nil
        }
    }

    func importFrom2FAS(json: JSON) -> [Token]? {
        var tokens: [Token] = []

        for (key, subJson) in json["services"] {
            guard
                let issuer = subJson["otp"]["issuer"].string,
                let account = subJson["otp"]["account"].string,
                let secret = subJson["secret"].string,
                let digits = subJson["otp"]["digits"].int,
                let counter = subJson["otp"]["counter"].int,
                let period = subJson["otp"]["period"].int,
                let algorithm = subJson["otp"]["algorithm"].string,
                let tokenAlgorithm = TokenAlgorithmEnum(rawValue: algorithm.uppercased()),
                let type = subJson["otp"]["tokenType"].string,
                let tokenType = TokenTypeEnum(rawValue: type.uppercased())
            else {
                logger.error("Error parsing token data for key: \(key)")
                continue
            }

            let token = Token()
            token.issuer = issuer
            token.account = account
            token.secret = secret
            token.digits = digits
            token.period = period
            token.counter = counter
            token.type = tokenType
            token.algorithm = tokenAlgorithm

            tokens.append(token)
        }

        if tokens.count != json["services"].count {
            return nil
        }

        return tokens
    }

    func importFromRaivo(json: JSON) -> [Token]? {
        var tokens: [Token] = []

        for (key, subJson) in json {
            guard
                let issuer = subJson["issuer"].string,
                let account = subJson["account"].string,
                let secret = subJson["secret"].string,

                let digitsString = subJson["digits"].string,
                let digits = Int(digitsString),

                let periodString = subJson["timer"].string,
                let period = Int(periodString),

                let counterString = subJson["counter"].string,
                let counter = Int(counterString),

                let kind = subJson["kind"].string,
                let algorithm = subJson["algorithm"].string,
                let tokenType = TokenTypeEnum(rawValue: kind),
                let tokenAlgorithm = TokenAlgorithmEnum(rawValue: algorithm)
            else {
                logger.error("Error parsing token data for key: \(key)")
                continue
            }

            let token = Token()
            token.issuer = issuer
            token.account = account
            token.secret = secret
            token.digits = digits
            token.period = period
            token.counter = counter
            token.type = tokenType
            token.algorithm = tokenAlgorithm

            tokens.append(token)
        }

        return tokens
    }

    func importFromAegis(json: JSON) -> [Token]? {
        var tokens: [Token] = []

        for (key, subJson) in json["db"]["entries"] {
            guard
                let issuer = subJson["issuer"].string,
                let account = subJson["name"].string,
                let secret = subJson["info"]["secret"].string,
                let digits = subJson["info"]["digits"].int,
                let type = subJson["type"].string,
                let algorithm = subJson["info"]["algo"].string,
                let tokenType = TokenTypeEnum(rawValue: type.uppercased()),
                let tokenAlgorithm = TokenAlgorithmEnum(rawValue: algorithm.uppercased())
            else {
                logger.error("Error parsing token data for key: \(key)")
                continue
            }

            let token = Token()
            token.issuer = issuer
            token.account = account
            token.secret = secret
            token.digits = digits
            token.type = tokenType
            token.algorithm = tokenAlgorithm

            switch tokenType {
            case .TOTP:
                guard let period = subJson["info"]["period"].int
                else {
                    logger.error("Error parsing TOTP data for key: \(key)")
                    continue
                }
                token.period = period

            case .HOTP:
                guard let counter = subJson["info"]["counter"].int
                else {
                    logger.error("Error parsing HOTP data for key: \(key)")
                    continue
                }
                token.counter = counter
            }

            tokens.append(token)
        }

        if tokens.count != json["db"]["entries"].count {
            return nil
        }

        return tokens
    }

    func importFromLastpass(json: JSON) -> [Token]? {
        var tokens: [Token] = []

        for (key, subJson) in json["accounts"] {
            guard
                let issuer = subJson["issuerName"].string,
                let account = subJson["userName"].string,
                let secret = subJson["secret"].string,
                let digits = subJson["digits"].int,
                let period = subJson["timeStep"].int,
                let algorithm = subJson["algorithm"].string,
                let tokenAlgorithm = TokenAlgorithmEnum(rawValue: algorithm.uppercased())
            else {
                logger.error("Error parsing token data for key: \(key)")
                continue
            }

            let token = Token()
            token.issuer = issuer
            token.account = account
            token.secret = secret
            token.digits = digits
            token.period = period
            token.type = TokenTypeEnum.TOTP
            token.algorithm = tokenAlgorithm

            tokens.append(token)
        }

        if tokens.count != json["accounts"].count {
            return nil
        }

        return tokens
    }

    func importFromGoogleAuth(otpAuthMigration: String) -> [Token]? {
        guard let otpAuthMigrationUrl = URL(string: otpAuthMigration),
              let components = URLComponents(url: otpAuthMigrationUrl, resolvingAgainstBaseURL: false),
              let scheme = components.scheme, scheme == "otpauth-migration",
              let host = components.host, host == "offline",
              let query = components.queryItems,
              let dataItem = query.first(where: { $0.name == "data" }),
              let encodedData = dataItem.value?.removingPercentEncoding,
              let decodedData = Data(base64Encoded: encodedData),
              let gaTokens = try? MigrationPayload(serializedBytes: decodedData)
        else {
            return nil
        }

        var tokens: [Token] = []

        for gaToken in gaTokens.otpParameters {
            var tokenDigits = 6
            switch gaToken.digits {
            case .six:
                tokenDigits = 6
            case .eight:
                tokenDigits = 8
            default:
                tokenDigits = 6
            }

            var tokenType = TokenTypeEnum.TOTP
            switch gaToken.type {
            case .hotp:
                tokenType = TokenTypeEnum.HOTP
            case .totp:
                tokenType = TokenTypeEnum.TOTP
            default:
                tokenType = TokenTypeEnum.TOTP
            }

            var tokenAlgo = TokenAlgorithmEnum.SHA1
            switch gaToken.algorithm {
            case .sha1:
                tokenAlgo = TokenAlgorithmEnum.SHA1
            case .sha256:
                tokenAlgo = TokenAlgorithmEnum.SHA256
            case .sha512:
                tokenAlgo = TokenAlgorithmEnum.SHA512
            case .md5:
                return nil
            default:
                tokenAlgo = TokenAlgorithmEnum.SHA1
            }

            let token = Token()
            token.issuer = gaToken.issuer
            token.account = gaToken.name
            token.digits = tokenDigits
            token.type = tokenType
            token.algorithm = tokenAlgo
            token.secret = gaToken.secret.base32EncodedString

            if tokenType == .TOTP {
                token.period = 30 // GA only allows 30 secs
            }

            if tokenType == .HOTP {
                token.counter = Int(gaToken.counter)
            }

            tokens.append(token)
        }

        if tokens.count != gaTokens.otpParameters.count {
            return nil
        }

        return tokens
    }
}
