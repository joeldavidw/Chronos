import Factory
import Foundation
import Logging
import SwiftyJSON

public class ImportService {
    private let logger = Logger(label: "ImportService")

    private let vaultService = Container.shared.vaultService()

    func importFromChronos(url: URL) -> [Token]? {
        if url.startAccessingSecurityScopedResource() {
            do {
                let jsonData = try String(contentsOf: url)
                let json = JSON(parseJSON: jsonData)

                let decoder = JSONDecoder()
                let tokens = try decoder.decode([Token].self, from: json["tokens"].rawData())
                return tokens
            } catch {
                print(error)
            }
        }
        url.stopAccessingSecurityScopedResource()

        return nil
    }
}
