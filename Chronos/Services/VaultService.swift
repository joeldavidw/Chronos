import Factory
import Foundation
import Logging
import SwiftData

public class VaultService {
    private let logger = Logger(label: "VaultService")

    private let stateService = Container.shared.stateService()
    private let swiftDataService = Container.shared.swiftDataService()

    // TODO(joeldavidw): Selects first vault for now. Selection page should be shown if there are more than one vault.
    func getFirstVault(isRestore: Bool) -> Vault? {
        let context = ModelContext(swiftDataService.getModelContainer(isRestore: isRestore))

        guard let vaultArr = try? context.fetch(FetchDescriptor<Vault>(sortBy: [SortDescriptor(\.createdAt)])) else {
            logger.error("No vaults found")
            return nil
        }

        guard let vault = vaultArr.first else {
            logger.error("Empty vaultArr")
            return nil
        }

        return vault
    }

    func getVault() -> Vault? {
        guard let vaultId: UUID = stateService.getVaultId() else {
            logger.error("vaultId not found in AppStorage")
            return nil
        }

        let context = ModelContext(swiftDataService.getModelContainer())

        let predicate = #Predicate<Vault> { $0.vaultId == vaultId }

        guard let vaultArr = try? context.fetch(FetchDescriptor<Vault>(predicate: predicate)) else {
            logger.error("No vaults found")
            return nil
        }

        return vaultArr.first
    }
}