@testable import Chronos
import SwiftyJSON
import XCTest

final class ChronosTests: XCTestCase {
    func testValidImport() throws {
        let json: JSON = [
            "tokens": [
                [
                    "digits": 6,
                    "type": "HOTP",
                    "counter": 11,
                    "algorithm": "SHA1",
                    "issuer": "Apple",
                    "account": "Test HOTP",
                    "period": 30,
                    "secret": "ffff",
                ],
                [
                    "counter": 0,
                    "issuer": "Apple",
                    "period": 30,
                    "type": "TOTP",
                    "algorithm": "SHA256",
                    "digits": 7,
                    "account": "Test TOTP",
                    "secret": "ff",
                ],
            ],
        ]

        let importService = ImportService()
        let tokens = importService.importFromChronos(json: json)!

        XCTAssertEqual(tokens.count, 2)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[0].counter, 11)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Apple")
        XCTAssertEqual(tokens[0].account, "Test HOTP")
        XCTAssertEqual(tokens[0].period, 30)
        XCTAssertEqual(tokens[0].secret, "ffff")

        XCTAssertEqual(tokens[1].digits, 7)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].counter, 0)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[1].issuer, "Apple")
        XCTAssertEqual(tokens[1].account, "Test TOTP")
        XCTAssertEqual(tokens[1].period, 30)
        XCTAssertEqual(tokens[1].secret, "ff")
    }
    
    func testValidWithAdditionalDataImport() throws {
        let json: JSON = [
            "tokens": [
                [
                    "digits": 6,
                    "type": "HOTP",
                    "counter": 11,
                    "algorithm": "SHA1",
                    "issuer": "Apple",
                    "account": "Test HOTP",
                    "period": 30,
                    "secret": "ffff",
                    "pinned": true,
                    "tags": ["Tag 1", "Tag 2"],
                ],
                [
                    "counter": 0,
                    "issuer": "Apple",
                    "period": 30,
                    "type": "TOTP",
                    "algorithm": "SHA256",
                    "digits": 7,
                    "account": "Test TOTP",
                    "secret": "ff",
                    "pinned": false,
                    "tags": [],
                ],
            ],
        ]

        let importService = ImportService()
        let tokens = importService.importFromChronos(json: json)!

        XCTAssertEqual(tokens.count, 2)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[0].counter, 11)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Apple")
        XCTAssertEqual(tokens[0].account, "Test HOTP")
        XCTAssertEqual(tokens[0].period, 30)
        XCTAssertEqual(tokens[0].secret, "ffff")
        XCTAssertEqual(tokens[0].pinned, true)
        XCTAssertEqual(tokens[0].tags, ["Tag 1", "Tag 2"])

        XCTAssertEqual(tokens[1].digits, 7)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].counter, 0)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[1].issuer, "Apple")
        XCTAssertEqual(tokens[1].account, "Test TOTP")
        XCTAssertEqual(tokens[1].period, 30)
        XCTAssertEqual(tokens[1].secret, "ff")
        XCTAssertEqual(tokens[1].pinned, false)
        XCTAssertEqual(tokens[1].tags, [])

    }

    func testInvalidImport_MissingVariables() throws {
        let json: JSON = [
            "tokens": [
                [
                    "counter": 0,
                    "issuer": "Apple",
                    "period": 30,
                    "type": "TOTP",
                    "algorithm": "SHA256",
                    "digits": 7,
                    "account": "Test TOTP",
                ],
            ],
        ]

        let importService = ImportService()
        let tokens = importService.importFromChronos(json: json)

        XCTAssertNil(tokens)
    }
}
