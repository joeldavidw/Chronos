import Factory
import Foundation
import Logging
import SwiftData
import ZipArchive

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

    private func getExportVault() -> ExportVault? {
        let context = ModelContext(swiftDataService.getModelContainer())
        guard let vault = vaultService.getVault(context: context) else {
            logger.error("Vault missing")
            return nil
        }

        var tokens: [Token] = []
        for encToken in vault.encryptedTokens ?? [] {
            guard let token = cryptoService.decryptToken(encryptedToken: encToken) else {
                logger.error("Unable to decode token")
                continue
            }
            tokens.append(token)
        }

        let exportVault = ExportVault()
        exportVault.tokens = tokens
        return exportVault
    }

    private func createUniqueDir() -> URL? {
        let uniqueDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("export", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: uniqueDir, withIntermediateDirectories: true)
        } catch {
            logger.error("Unable to create temporary directory: \(error.localizedDescription)")
            return nil
        }
        return uniqueDir
    }

    private func writeJSON(to url: URL, from exportVault: ExportVault) -> Bool {
        guard let jsonData = try? JSONEncoder().encode(exportVault) else {
            logger.error("Unable to encode exportVault")
            return false
        }

        do {
            try jsonData.write(to: url)
            return true
        } catch {
            logger.error("Unable to write json file: \(error.localizedDescription)")
            return false
        }
    }

    func exportToUnencryptedJson() -> URL? {
        guard let exportVault = getExportVault(), let uniqueDir = createUniqueDir() else {
            return nil
        }

        let url = uniqueDir.appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("json")

        if writeJSON(to: url, from: exportVault) {
            return url
        }

        return nil
    }

    func exportToEncryptedZip(password: String) -> URL? {
        guard let exportVault = getExportVault(), let uniqueDir = createUniqueDir() else {
            return nil
        }

        let jsonUrl = uniqueDir.appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("json")

        if !writeJSON(to: jsonUrl, from: exportVault) {
            return nil
        }

        let zipUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent("export", isDirectory: true)
            .appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("zip")

        let success = SSZipArchive.createZipFile(
            atPath: zipUrl.path,
            withContentsOfDirectory: uniqueDir.path,
            keepParentDirectory: false,
            compressionLevel: 0,
            password: password,
            aes: true
        )

        if success {
            return zipUrl
        }

        logger.error("Failed to create zip file")
        return nil
    }

    func cleanupTemporaryDirectory() {
        do {
            let tempExportDirUrl = FileManager.default.temporaryDirectory
                .appendingPathComponent("export", isDirectory: true)

            try FileManager.default.removeItem(at: tempExportDirUrl)
        } catch {
            logger.error("Unable to delete temporary directory: \(error.localizedDescription)")
        }
    }
}
