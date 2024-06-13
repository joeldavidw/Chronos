import Foundation
import Logging
import SwiftData

public class SwiftDataService {
    let logger = Logger(label: "SwiftDataModelSingleton")

    let defaults = UserDefaults.standard

    private lazy var localModelContainer: ModelContainer = setupModelContainer(storeName: "localChronos.sqlite", cloudKitDatabase: .none)

    private lazy var cloudModelContainer: ModelContainer = setupModelContainer(storeName: "onlineChronos.sqlite", cloudKitDatabase: .automatic)

    let schema = Schema([Vault.self, ChronosCrypto.self, EncryptedToken.self])

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
    func doesICloudBackupExist() -> Bool {
        let container = getCloudModelContainer()
        let context = ModelContext(container)
        let cryptoArr = try! context.fetch(FetchDescriptor<ChronosCrypto>())

        return !cryptoArr.isEmpty
    }

    func deleteLocallyPersistedChronosData() {
        getLocalModelContainer().deleteAllData()
        getCloudModelContainer().deleteAllData()
        resetModelContainers()
    }

    func deleteCloudChronosCryptoData() -> Bool {
        let container = getCloudModelContainer()
        let modelContext = ModelContext(container)
        try? modelContext.delete(model: ChronosCrypto.self)
        try? modelContext.delete(model: EncryptedToken.self)
        try? modelContext.save()
        return true
    }
}
