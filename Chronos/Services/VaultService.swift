import Factory
import Foundation
import Logging
import SwiftData

public class VaultService {
    private let logger = Logger(label: "VaultService")

    private let stateService = Container.shared.stateService()
    private let swiftDataService = Container.shared.swiftDataService()

    func createVault(chronosCrypto: ChronosCrypto) -> Vault? {
        let context = ModelContext(swiftDataService.getModelContainer())

        let vault = Vault(vaultId: UUID(), createdAt: Date())

        vault.chronosCryptos = [chronosCrypto]

        context.insert(vault)

        do {
            try context.save()
            logger.info("Successfully saved vault")

            return vault
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
            return nil
        }
    }

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

extension VaultService {
    func insertEncryptedToken(_ encryptedToken: EncryptedToken) {
        let context = ModelContext(swiftDataService.getModelContainer())

        let vault = getVault()!

        vault.encryptedTokens?.append(encryptedToken)

        context.insert(vault)

        do {
            try context.save()
            logger.info("Successfully saved vault")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }

    func deleteEncryptedToken(_ encryptedToken: EncryptedToken) {
        let context = ModelContext(swiftDataService.getModelContainer())

        let vault = getVault()!

        vault.encryptedTokens?.append(encryptedToken)

        context.insert(vault)

        do {
            try context.save()
            logger.info("Successfully saved vault")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
        }
    }
}
