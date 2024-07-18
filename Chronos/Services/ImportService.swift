import Factory
import Foundation
import Logging
import SwiftyJSON

public class ImportService {
    private let logger = Logger(label: "ImportService")
    private let vaultService = Container.shared.vaultService()

    func importTokens(importSource: ImportSource, url: URL) -> [Token]? {
        guard let json = readFile(url: url) else {
            logger.error("Failed to read file at \(url)")
            return nil
        }

        switch importSource.id {
        case "chronos":
            return importFromChronos(json: json)
        case "raivo":
            return importFromRaivo(json: json)
        default:
            logger.error("Unsupported import source: \(importSource.id)")
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
}
