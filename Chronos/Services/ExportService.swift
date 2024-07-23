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
        exportVault.schemaVersion = 1
        exportVault.tokens = tokens.sorted(by: { token1, token2 in
            token1.issuer.localizedCaseInsensitiveCompare(token2.issuer) == .orderedAscending
        })
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

    func exportHtml() -> URL? {
        guard let exportVault = getExportVault(), let uniqueDir = createUniqueDir() else {
            return nil
        }

        var tokensHtml: [Node] = []

        for token in exportVault.tokens! {
            tokensHtml.append(tokenDetailsDiv(token: token))
        }

        let htmlUrl = uniqueDir.appendingPathComponent("Chronos_" + Date().formatted(verbatimStyle))
            .appendingPathExtension("html")

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
                            border-radius: 10px;
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
                        @media (max-width: 600px) {
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
                         .h2(attributes: [.style(safe: "font-weight: 500; text-align: right;")], "No. of Tokens: \(exportVault.tokens!.count.description)")),
                    .hr(),
                    .div(attributes: [.class("token-container")],
                         .fragment(tokensHtml))
                )
            )
        )

        if writeHTML(to: htmlUrl, from: render(document)) {
            return htmlUrl
        }

        return nil
    }

    func tokenDetailsDiv(token: Token) -> Node {
        var base64Img = ""
        if let otpAuthUrl = otpService.tokenToOtpAuthUrl(token: token),
           let image = EFQRCode.generate(for: otpAuthUrl)
        {
            base64Img = UIImage(cgImage: image).pngData()?.base64EncodedString() ?? ""
        }

        var periodNode: Node = .text("")
        if token.type.rawValue == "TOTP" {
            periodNode = .div(attributes: [.style(safe: "margin: 5px 0;")], .text("Period: "), .code(attributes: [.style(safe: "background-color: #f8f8f8; padding: 2px 4px; border-radius: 3px;")], "\(token.period.description)"))
        }

        var counterNode: Node = .text("")
        if token.type.rawValue == "HOTP" {
            counterNode = .div(attributes: [.style(safe: "margin: 5px 0;")], .text("Counter: "), .code(attributes: [.style(safe: "background-color: #f8f8f8; padding: 2px 4px; border-radius: 3px;")], "\(token.counter.description)"))
        }

        let node = Node.div(attributes: [.class("token-card")],
                            .div(attributes: [.class("token-details")],
                                 .div(attributes: [.class("token-info")],
                                      .h3(attributes: [.style(safe: "margin: 0 0 10px; font-size: 1.5em;")], .text(token.issuer)),
                                      .h4(attributes: [.style(safe: "margin: 0 0 10px; font-size: 1.2em; color: #555;")], .text(token.account)),
                                      .div(attributes: [.style(safe: "margin: 5px 0;")], .text("Secret: "), .code(attributes: [.style(safe: "background-color: #f8f8f8; padding: 2px 4px; border-radius: 3px;")], "\(token.secret)")),
                                      .div(attributes: [.style(safe: "margin: 5px 0;")], .text("Type: "), .code(attributes: [.style(safe: "background-color: #f8f8f8; padding: 2px 4px; border-radius: 3px;")], "\(token.type.rawValue)")),
                                      .div(attributes: [.style(safe: "margin: 5px 0;")], .text("Algorithm: "), .code(attributes: [.style(safe: "background-color: #f8f8f8; padding: 2px 4px; border-radius: 3px;")], "\(token.algorithm.rawValue)")),
                                      .div(attributes: [.style(safe: "margin: 5px 0;")], .text("Digits: "), .code(attributes: [.style(safe: "background-color: #f8f8f8; padding: 2px 4px; border-radius: 3px;")], "\(token.digits.description)")),
                                      periodNode,
                                      counterNode),
                                 .div(attributes: [.style(safe: "flex: 0 0 auto;")],
                                      .img(base64: base64Img, type: .image(.png), alt: "", attributes: [.width(150), .height(150)]))))
        return node
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

extension ExportService {
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

    private func writeHTML(to url: URL, from htmlString: String) -> Bool {
        let htmlData = Data(htmlString.utf8)

        do {
            try htmlData.write(to: url)
            return true
        } catch {
            logger.error("Unable to write json file: \(error.localizedDescription)")
            return false
        }
    }
}
