@testable import Chronos
import SwiftyJSON
import XCTest

final class LastPassTests: XCTestCase {
    func testValidImport() throws {
        let json: JSON =
            [
                "accounts": [
                    [
                        "accountID": "",
                        "algorithm": "SHA1",
                        "creationTimestamp": 1_722_179_392,
                        "digits": 6,
                        "folderData": [
                            "folderId": 0,
                            "position": 0,
                        ],
                        "isFavorite": false,
                        "issuerName": "Lith",
                        "lmiUserId": "",
                        "originalIssuerName": "",
                        "originalUserName": "Shanks",
                        "secret": "KQOZTMLOJBSMYWIO4BG4UTXDSR",
                        "timeStep": 30,
                        "userName": "Shanks",
                    ],
                    [
                        "accountID": "",
                        "algorithm": "SHA256",
                        "creationTimestamp": 1_722_180_037,
                        "digits": 7,
                        "folderData": [
                            "folderId": 0,
                            "position": 1,
                        ],
                        "isFavorite": false,
                        "issuerName": "Ludi",
                        "lmiUserId": "",
                        "originalIssuerName": "Ludi",
                        "originalUserName": "Roly Poly",
                        "secret": "LI3SJSNME7PSCQCXL2TIFMNH64",
                        "timeStep": 60,
                        "userName": "Roly Poly",
                    ],
                    [
                        "accountID": "",
                        "algorithm": "SHA256",
                        "creationTimestamp": 1_722_180_037,
                        "digits": 8,
                        "folderData": [
                            "folderId": 0,
                            "position": 1,
                        ],
                        "isFavorite": false,
                        "issuerName": "",
                        "lmiUserId": "",
                        "originalIssuerName": "",
                        "originalUserName": "Todd",
                        "secret": "F7E5IPN2KYUXE5WZLMSRVTFK7N",
                        "timeStep": 60,
                        "userName": "Todd",
                    ],
                ],
                "deviceName": "iPhone16,2",
                "folders": [
                    [
                        "id": 1,
                        "isOpened": true,
                        "name": "Favorites",
                    ],
                    [
                        "id": 0,
                        "isOpened": true,
                        "name": "Other Accounts",
                    ],
                ],
                "localDeviceId": "E21FD688-A948-4773-8AD5-4EEECFBF82E4",
                "version": 1,
            ]

        let importService = ImportService()
        let tokens = importService.importFromLastpass(json: json)!

        XCTAssertEqual(tokens.count, 3)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Lith")
        XCTAssertEqual(tokens[0].account, "Shanks")
        XCTAssertEqual(tokens[0].period, 30)
        XCTAssertEqual(tokens[0].secret, "KQOZTMLOJBSMYWIO4BG4UTXDSR")

        XCTAssertEqual(tokens[1].digits, 7)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[1].issuer, "Ludi")
        XCTAssertEqual(tokens[1].account, "Roly Poly")
        XCTAssertEqual(tokens[1].period, 60)
        XCTAssertEqual(tokens[1].secret, "LI3SJSNME7PSCQCXL2TIFMNH64")

        XCTAssertEqual(tokens[2].digits, 8)
        XCTAssertEqual(tokens[2].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[2].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[2].issuer, "")
        XCTAssertEqual(tokens[2].account, "Todd")
        XCTAssertEqual(tokens[2].period, 60)
        XCTAssertEqual(tokens[2].secret, "F7E5IPN2KYUXE5WZLMSRVTFK7N")
    }
}
