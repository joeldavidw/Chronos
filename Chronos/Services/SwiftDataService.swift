import Foundation
import Logging
import SwiftData

public class SwiftDataService {
    private let logger = Logger(label: "SwiftDataModelSingleton")

    private let defaults = UserDefaults.standard

    private lazy var localModelContainer: ModelContainer = setupModelContainer(storeName: "localChronos.sqlite", cloudKitDatabase: .none)

    private lazy var cloudModelContainer: ModelContainer = setupModelContainer(storeName: "onlineChronos.sqlite", cloudKitDatabase: .automatic)

    private let schema = Schema([Vault.self, ChronosCrypto.self, EncryptedToken.self])

    init() {
        _ = localModelContainer
        _ = cloudModelContainer
    }

    private func setupModelContainer(storeName: String, cloudKitDatabase: ModelConfiguration.CloudKitDatabase) -> ModelContainer {
        let storeURL = URL.documentsDirectory.appendingPathComponent(storeName)
        let modelConfig = ModelConfiguration(url: storeURL, cloudKitDatabase: cloudKitDatabase)

        do {
            let container = try ModelContainer(for: schema, configurations: modelConfig)
            logger.info("Initialized container for \(storeName)")
            return container
        } catch {
            fatalError("Cannot set up modelContainer for \(storeName): \(error.localizedDescription)")
        }
    }

    public func getModelContainer(isRestore: Bool = false) -> ModelContainer {
        if isRestore {
            return cloudModelContainer
        }

        let isICloudEnabled = defaults.bool(forKey: StateEnum.ICLOUD_BACKUP_ENABLED.rawValue)

        if isICloudEnabled {
            logger.info("Returned CloudContainer")
            return cloudModelContainer
        }

        logger.info("Returned LocalContainer")
        return localModelContainer
    }

    public func resetModelContainers() {
        localModelContainer = setupModelContainer(storeName: "localChronos.sqlite", cloudKitDatabase: .none)
        cloudModelContainer = setupModelContainer(storeName: "onlineChronos.sqlite", cloudKitDatabase: .automatic)
    }

    public func getCloudModelContainer() -> ModelContainer {
        return cloudModelContainer
    }

    public func getLocalModelContainer() -> ModelContainer {
        return localModelContainer
    }
}

extension SwiftDataService {
    func deleteLocallyPersistedChronosData() {
        getLocalModelContainer().deleteAllData()
        getCloudModelContainer().deleteAllData()
        resetModelContainers()
    }
}
