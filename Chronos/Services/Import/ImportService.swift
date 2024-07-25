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
        case .RAIVO:
            return importFromRaivo(json: json)
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

    private func importFromRaivo(json: JSON) -> [Token]? {
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

    private func importFromGoogleAuth(otpAuthMigration: String) -> [Token]? {
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
            token.period = 30
            token.counter = Int(gaToken.counter)
            token.type = tokenType
            token.algorithm = tokenAlgo
            token.secret = gaToken.secret.base32EncodedString

            tokens.append(token)
        }

        if tokens.count != gaTokens.otpParameters.count {
            return nil
        }

        return tokens
    }
}
