import Factory
import Foundation
import SwiftData

public class ExportService {
    let swiftDataService = Container.shared.swiftDataService()
    let cryptoService = Container.shared.cryptoService()

    let verbatimStyle = Date.VerbatimFormatStyle(
        format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
        timeZone: .autoupdatingCurrent,
        calendar: Calendar(identifier: .gregorian)
    )

    func exportToUnencryptedJson() -> URL? {
        let context = ModelContext(swiftDataService.getModelContainer())
        let encryptedTokenArr = try! context.fetch(FetchDescriptor<EncryptedToken>())

        var tokens: [Token] = []

        do {
            for encToken in encryptedTokenArr {
                let token = cryptoService.decryptToken(encryptedToken: encToken)
                tokens.append(token!)
            }

            let data = ChronosData(tokens: tokens)

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
                .appendingPathExtension("json")

            let jsonData = try JSONEncoder().encode(data)
            try jsonData.write(to: url)

            throw OTPError.invalidSecret

            return url
        } catch {
            return nil
        }
    }
}
