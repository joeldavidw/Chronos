@testable import Chronos
import SwiftyJSON
import XCTest

final class RaivoTests: XCTestCase {
    func testValidImport() throws {
        let json: JSON = [
            [
              "secret": "ff",
              "timer": "30",
              "account": "Test HOTP",
              "kind": "HOTP",
              "algorithm": "SHA1",
              "digits": "6",
              "pinned": "false",
              "iconValue": "",
              "counter": "12",
              "issuer": "Raivo",
              "iconType": ""
            ],
            [
              "issuer": "Raivo",
              "secret": "JBSWY3DPEHPK3PXP",
              "iconType": "",
              "iconValue": "",
              "pinned": "false",
              "algorithm": "SHA1",
              "digits": "6",
              "kind": "TOTP",
              "timer": "30",
              "counter": "0",
              "account": "Test TOTP"
            ]
          ]

        let importService = ImportService()
        let tokens = importService.importFromRaivo(json: json)!

        XCTAssertEqual(tokens.count, 2)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[0].counter, 12)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Raivo")
        XCTAssertEqual(tokens[0].account, "Test HOTP")
        XCTAssertEqual(tokens[0].period, 30)
        XCTAssertEqual(tokens[0].secret, "ff")

        XCTAssertEqual(tokens[1].digits, 6)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].counter, 0)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[1].issuer, "Raivo")
        XCTAssertEqual(tokens[1].account, "Test TOTP")
        XCTAssertEqual(tokens[1].period, 30)
        XCTAssertEqual(tokens[1].secret, "JBSWY3DPEHPK3PXP")
    }

    func testInvalidImport_MissingVariables() throws {
        let json: JSON = [
            [
              "issuer": "Raivo",
              "iconType": "",
              "iconValue": "",
              "pinned": "false",
              "algorithm": "SHA1",
              "digits": "6",
              "kind": "TOTP",
              "timer": "30",
              "counter": "0",
              "account": "Test TOTP"
            ]
          ]

        let importService = ImportService()
        let tokens = importService.importFromChronos(json: json)

        XCTAssertNil(tokens)
    }
}
