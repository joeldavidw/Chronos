import Foundation
import Logging
import SwiftData

public class SwiftDataService {
    private let logger = Logger(label: "SwiftDataModelSingleton")

    private let defaults = UserDefaults.standard

    private lazy var localModelContainer: ModelContainer = setupModelContainer(storeName: "localChronos.sqlite", cloudKitDatabase: .none)

    private lazy var cloudModelContainer: ModelContainer = setupModelContainer(storeName: "onlineChronos.sqlite", cloudKitDatabase: .automatic)

    private let schema = Schema([Vault.self, ChronosCrypto.self, EncryptedToken.self])

    private var storeDir = URL.applicationSupportDirectory.appendingPathComponent("ChronosStore", isDirectory: true)

    init() {
        initChronosStoreDir()
        // Remove this in subsequent version
        moveFileIfNecessary()

        _ = localModelContainer
        _ = cloudModelContainer
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

    private func setupModelContainer(storeName: String, cloudKitDatabase: ModelConfiguration.CloudKitDatabase) -> ModelContainer {
        var storeURL = storeDir.appendingPathComponent(storeName)
        let modelConfig = ModelConfiguration(url: storeURL, cloudKitDatabase: cloudKitDatabase)

        do {
            let container = try ModelContainer(for: schema, configurations: modelConfig)
            logger.info("Initialized container for \(storeName)")

            setStoreDirExcludedFromBackup()

            return container
        } catch {
            fatalError("Cannot set up modelContainer for \(storeName): \(error.localizedDescription)")
        }
    }

    private func initChronosStoreDir() {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: storeDir.path) {
            do {
                try fileManager.createDirectory(at: storeDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.error("initChronosStoreDir - unable to create dir: \(error)")
            }
        }

        setStoreDirExcludedFromBackup()
    }

    private func setStoreDirExcludedFromBackup() {
        do {
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try storeDir.setResourceValues(values)
            logger.info("Successfully set isExcludedFromBackup for directory: \(storeDir)")

        } catch {
            logger.error("Unable to set isExcludedFromBackup for directory \(storeDir): \(error)")
        }

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: storeDir.path)

            for item in items {
                var itemURL = storeDir.appendingPathComponent(item)
                do {
                    var values = URLResourceValues()
                    values.isExcludedFromBackup = true
                    try itemURL.setResourceValues(values)
                    logger.info("Successfully set isExcludedFromBackup for file \(itemURL)")
                } catch {
                    logger.error("Unable to set isExcludedFromBackup for file \(itemURL): \(error)")
                }
            }
        } catch {
            logger.error("Failed to read directory at \(storeDir.path): \(error)")
        }
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
    private func moveFileIfNecessary() {
        for fileName in ["localChronos.sqlite", "localChronos.sqlite-wal", "localChronos.sqlite-shm", "onlineChronos.sqlite", "onlineChronos.sqlite-shm", "onlineChronos.sqlite-wal", ".onlineChronos_SUPPORT", "onlineChronos_ckAssets"] {
            let oldStoreURL = URL.documentsDirectory.appendingPathComponent(fileName)
            let newStoreURL = storeDir.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: newStoreURL.path) {
                logger.info("New store location already found. Stopping migration of old store.")
                return
            }

            if FileManager.default.fileExists(atPath: oldStoreURL.path) {
                do {
                    try FileManager.default.moveItem(at: oldStoreURL, to: newStoreURL)
                    logger.info("File moved successfully to \(newStoreURL)")
                } catch {
                    logger.error("Error moving file: \(error)")
                }
            } else {
                logger.info("File does not exist at \(oldStoreURL)")
            }
        }
        setStoreDirExcludedFromBackup()
    }
}

extension SwiftDataService {
    func doesICloudBackupExist() -> Bool {
        let container = getCloudModelContainer()
        let context = ModelContext(container)
        let vaults = try! context.fetch(FetchDescriptor<Vault>())

        return !vaults.isEmpty
    }

    func deleteLocallyPersistedChronosData() {
        getLocalModelContainer().deleteAllData()
        resetModelContainers()
    }

    func permentalyDeleteAllIcloudData() {
        let container = getCloudModelContainer()
        let context = ModelContext(container)
        let vaults = try! context.fetch(FetchDescriptor<Vault>())
        for vault in vaults {
            context.delete(vault)
        }
    }
}
