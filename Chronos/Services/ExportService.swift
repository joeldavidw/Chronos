import Factory
import Foundation
import Logging
import SwiftData

public class ExportService {
    private let logger = Logger(label: "ExportService")
    private let swiftDataService = Container.shared.swiftDataService()
    private let cryptoService = Container.shared.cryptoService()
    private let vaultService = Container.shared.vaultService()

    private let verbatimStyle = Date.VerbatimFormatStyle(
        format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
        timeZone: .autoupdatingCurrent,
        calendar: Calendar(identifier: .gregorian)
    )

    func exportToUnencryptedJson() -> URL? {
        let context = ModelContext(swiftDataService.getModelContainer())
        let vault = vaultService.getVault(context: context)

        let exportVault = ExportVault()

        var tokens: [Token] = []

        for encToken in vault!.encryptedTokens! {
            guard let token = cryptoService.decryptToken(encryptedToken: encToken) else {
                logger.error("Unable to decode token")
                continue
            }
            tokens.append(token)
        }

        exportVault.tokens = tokens

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("json")

        guard let jsonData = try? JSONEncoder().encode(exportVault) else {
            logger.error("Unable to encode exportVault")
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
