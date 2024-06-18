import Factory
import Foundation
import Logging
import SwiftData

public class VaultService {
    private let logger = Logger(label: "VaultService")

    private let stateService = Container.shared.stateService()
    private let swiftDataService = Container.shared.swiftDataService()

    func createVaultCrypto(vaultName: String, chronosCrypto: ChronosCrypto) -> Bool {
        let context = ModelContext(swiftDataService.getModelContainer())
        let vault = Vault(vaultId: UUID(), name: vaultName, createdAt: Date())
        vault.chronosCryptos = [chronosCrypto]
        context.insert(vault)

        do {
            try context.save()
            logger.info("Successfully saved vault with chronosCrypto")

            stateService.setVaultId(vaultId: vault.vaultId!)
            return true
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
            return false
        }
    }

    func getVaultFromCloudContainer() -> Vault? {
        guard let vaultId: UUID = stateService.getVaultId() else {
            logger.error("vaultId not found in AppStorage")
            return nil
        }

        let predicate = #Predicate<Vault> { $0.vaultId == vaultId }
        let context = ModelContext(swiftDataService.getCloudModelContainer())

        do {
            let vaultArr = try context.fetch(FetchDescriptor<Vault>(predicate: predicate))
            if let vault = vaultArr.first {
                logger.info("Returning vault \(vault.name)")
                return vault
            } else {
                logger.error("No vaults found with the given vaultId")
                return nil
            }
        } catch {
            logger.error("Failed to fetch vaults: \(error.localizedDescription)")
            return nil
        }
    }
}

extension VaultService {
    private func getVault(context: ModelContext) -> Vault? {
        guard let vaultId: UUID = stateService.getVaultId() else {
            logger.error("vaultId not found in AppStorage")
            return nil
        }

        let predicate = #Predicate<Vault> { $0.vaultId == vaultId }

        do {
            let vaultArr = try context.fetch(FetchDescriptor<Vault>(predicate: predicate))
            if let vault = vaultArr.first {
                logger.info("Returning vault \(vault.name)")
                return vault
            } else {
                logger.error("No vaults found with the given vaultId")
                return nil
            }
        } catch {
            logger.error("Failed to fetch vaults: \(error.localizedDescription)")
            return nil
        }
    }

    func insertEncryptedToken(_ encryptedToken: EncryptedToken) {
        let context = ModelContext(swiftDataService.getModelContainer())

        let vault = getVault(context: context)!

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

        let vault = getVault(context: context)!

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
