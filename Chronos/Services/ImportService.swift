import Factory
import Foundation
import Logging

public class ImportService {
    private let logger = Logger(label: "ImportService")

    private let vaultService = Container.shared.vaultService()

    func importFromChronos(url: URL) {
        print(url)
    }
}
