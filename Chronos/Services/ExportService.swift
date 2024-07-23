import EFQRCode
import Factory
import Foundation
import Html
import Logging
import SwiftData
import UIKit
import ZipArchive

public class ExportService {
    private let logger = Logger(label: "ExportService")
    private let swiftDataService = Container.shared.swiftDataService()
    private let cryptoService = Container.shared.cryptoService()
    private let vaultService = Container.shared.vaultService()
    private let otpService = Container.shared.otpService()

    private let verbatimStyle = Date.VerbatimFormatStyle(
        format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
        timeZone: .autoupdatingCurrent,
        calendar: Calendar(identifier: .gregorian)
    )

    private func exportJSONAndHtml(uniqueDir: URL, exportVault: ExportVault) -> Bool {
        var success = true

        if !exportJSON(uniqueDir: uniqueDir, exportVault: exportVault) {
            logger.error("Unable to export JSON file")
            success = false
        }

        if !exportHtml(uniqueDir: uniqueDir, exportVault: exportVault) {
            logger.error("Unable to export HTML file")
            success = false
        }

        return success
    }

    func exportToZip(password: String? = nil) -> URL? {
        guard let exportVault = getExportVault(), let uniqueDir = createUniqueDir() else {
            return nil
        }

        guard exportJSONAndHtml(uniqueDir: uniqueDir, exportVault: exportVault) else {
            return nil
        }

        let zipUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent("export", isDirectory: true)
            .appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("zip")

        let success: Bool

        if let password = password {
            success = SSZipArchive.createZipFile(
                atPath: zipUrl.path,
                withContentsOfDirectory: uniqueDir.path,
                keepParentDirectory: false,
                compressionLevel: 0,
                password: password,
                aes: true
            )
        } else {
            success = SSZipArchive.createZipFile(
                atPath: zipUrl.path,
                withContentsOfDirectory: uniqueDir.path,
                keepParentDirectory: false
            )
        }

        if success {
            return zipUrl
        }

        logger.error("Failed to create zip file")
        return nil
    }

    func cleanupTemporaryDirectory() {
        let tempExportDirUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent("export", isDirectory: true)

        do {
            try FileManager.default.removeItem(at: tempExportDirUrl)
        } catch {
            logger.error("Unable to delete temporary directory: \(error.localizedDescription)")
        }
    }
}

extension ExportService {
    private func getExportVault() -> ExportVault? {
        let context = ModelContext(swiftDataService.getModelContainer())
        guard let vault = vaultService.getVault(context: context) else {
            logger.error("Vault missing")
            return nil
        }

        let tokens = (vault.encryptedTokens ?? []).compactMap { encToken -> Token? in
            guard let token = cryptoService.decryptToken(encryptedToken: encToken) else {
                logger.error("Unable to decode token")
                return nil
            }
            return token
        }

        let exportVault = ExportVault()
        exportVault.schemaVersion = 1
        exportVault.tokens = tokens.sorted { $0.issuer.localizedCaseInsensitiveCompare($1.issuer) == .orderedAscending }
        return exportVault
    }

    private func createUniqueDir() -> URL? {
        let uniqueDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("export", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: uniqueDir, withIntermediateDirectories: true)
            return uniqueDir
        } catch {
            logger.error("Unable to create temporary directory: \(error.localizedDescription)")
            return nil
        }
    }
}

extension ExportService {
    private func exportJSON(uniqueDir: URL, exportVault: ExportVault) -> Bool {
        let jsonUrl = uniqueDir.appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("json")

        do {
            let jsonData = try JSONEncoder().encode(exportVault)
            try jsonData.write(to: jsonUrl)
            return true
        } catch {
            logger.error("Unable to write JSON file: \(error.localizedDescription)")
            return false
        }
    }

    private func writeHTML(to url: URL, from htmlString: String) -> Bool {
        do {
            let htmlData = Data(htmlString.utf8)
            try htmlData.write(to: url)
            return true
        } catch {
            logger.error("Unable to write HTML file: \(error.localizedDescription)")
            return false
        }
    }

    private func exportHtml(uniqueDir: URL, exportVault: ExportVault) -> Bool {
        let htmlUrl = uniqueDir.appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("html")

        let tokensHtml = exportVault.tokens?.map { tokenDetailsDiv(token: $0) } ?? []

        let document: Node = .document(
            .html(
                .head(
                    [.style(safe: """
                        body {
                            font-family: sans-serif;
                            max-width: 1000px;
                            margin: 0 auto;
                            padding: 20px;
                        }
                        .token-container {
                            display: flex;
                            flex-wrap: wrap;
                            justify-content: space-around;
                        }
                        .token-card {
                            flex: 1 0 45%;
                            margin: 10px;
                            padding: 20px;
                            border: 1px solid #ccc;
                            border-radius: 6px;
                            box-sizing: border-box;
                        }
                        .token-details {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                        }
                        .token-info {
                            flex: 1;
                            padding-right: 20px;
                            word-wrap: break-word;
                            overflow-wrap: break-word;
                            word-break: break-word;
                        }
                        .token-info div {
                            margin: 5px 0;
                        }
                        .token-info code {
                            background-color: #f8f8f8;
                            padding: 2px 4px;
                            border-radius: 3px;
                        }
                        .header-container {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                        }
                        @media (max-width: 800px) {
                            .token-card {
                                flex: 1 0 100%;
                            }
                        }
                    """)]
                ),
                .body(
                    .div(attributes: [.class("header-container")],
                         .h1(attributes: [.style(safe: "font-weight: 700;")], "Chronos Export"),
                         .div()),
                    .div(attributes: [.class("header-container")],
                         .h2(attributes: [.style(safe: "font-weight: 500; flex-grow: 1;")], "\(Date().formatted(verbatimStyle))"),
                         .h2(attributes: [.style(safe: "font-weight: 500; text-align: right;")], "No. of Tokens: \(exportVault.tokens?.count.description ?? "Error")")),
                    .hr(),
                    .div(attributes: [.class("token-container")],
                         .fragment(tokensHtml))
                )
            )
        )

        return writeHTML(to: htmlUrl, from: render(document))
    }

    func tokenDetailsDiv(token: Token) -> Node {
        let base64Img = otpService.tokenToOtpAuthUrl(token: token).flatMap { otpAuthUrl in
            EFQRCode.generate(for: otpAuthUrl).flatMap { image in
                UIImage(cgImage: image).pngData()?.base64EncodedString()
            }
        } ?? ""

        let periodNode: Node = token.type.rawValue == "TOTP" ? .div(.text("Period: "), .code("\(token.period.description)")) : .text("")

        let counterNode: Node = token.type.rawValue == "HOTP" ? .div(.text("Counter: "), .code("\(token.counter.description)")) : .text("")

        return Node.div(
            attributes: [.class("token-card")],
            .div(attributes: [.class("token-details")],
                 .div(attributes: [.class("token-info")],
                      .h3(attributes: [.style(safe: "margin: 0 0 10px; font-size: 1.5em;")], .text(token.issuer)),
                      .h4(attributes: [.style(safe: "margin: 0 0 10px; font-size: 1.2em; color: #555;")], .text(token.account)),
                      .div(.text("Secret: "), .code("\(token.secret)")),
                      .div(.text("Type: "), .code("\(token.type.rawValue)")),
                      .div(.text("Algorithm: "), .code("\(token.algorithm.rawValue)")),
                      .div(.text("Digits: "), .code("\(token.digits.description)")),
                      periodNode,
                      counterNode),
                 .div(attributes: [.style(safe: "flex: 0 0 auto;")],
                      .img(base64: base64Img, type: .image(.png), alt: "", attributes: [.width(150), .height(150)])))
        )
    }
}
