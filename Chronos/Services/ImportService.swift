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
}
