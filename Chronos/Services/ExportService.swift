import Factory
import Foundation
import Logging
import SwiftData

public class ExportService {
    private let logger = Logger(label: "ExportService")
    private let swiftDataService = Container.shared.swiftDataService()
    private let cryptoService = Container.shared.cryptoService()

    let verbatimStyle = Date.VerbatimFormatStyle(
        format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
        timeZone: .autoupdatingCurrent,
        calendar: Calendar(identifier: .gregorian)
    )

    func exportToUnencryptedJson() -> URL? {
        let context = ModelContext(swiftDataService.getModelContainer())
        let encryptedTokenArr = try! context.fetch(FetchDescriptor<EncryptedToken>())

        let chronosData = ChronosData()

        var tokens: [Token] = []
        var errors: [String] = []

        var numOfTokenFailedToDecode = 0

        for encToken in encryptedTokenArr {
            guard let token = cryptoService.decryptToken(encryptedToken: encToken) else {
                logger.error("Unable to decode token")
                numOfTokenFailedToDecode += 1
                continue
            }
            tokens.append(token)
        }

        if numOfTokenFailedToDecode != 0 {
            errors.append("\(numOfTokenFailedToDecode) out of \(encryptedTokenArr.count) tokens failed to be export")
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("json")

        guard let jsonData = try? JSONEncoder().encode(chronosData) else {
            logger.error("Unable to encode ChronosData")
            return nil
        }

        do {
            try jsonData.write(to: url)
        } catch {
            logger.error("Unable to write json file: \(error.localizedDescription)")
            return nil
        }

        return url
    }
}
