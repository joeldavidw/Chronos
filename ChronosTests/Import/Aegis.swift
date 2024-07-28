@testable import Chronos
import SwiftyJSON
import XCTest

final class AegisTests: XCTestCase {
    func testValidImport() throws {
        let json: JSON =
            [
                "version": 1,
                "header": [
                    "slots": nil,
                    "params": nil,
                ],
                "db": [
                    "version": 3,
                    "entries": [
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "totp",
                            "uuid": "ea250427-4465-48d7-bbcd-4616be85626a",
                            "name": "user1+totp@test.com",
                            "issuer": "Apple",
                            "icon": nil,
                            "info": [
                                "secret": "AB6B7FAYHW2G42ZA4FJHLRWWHU",
                                "algo": "SHA1",
                                "digits": 6,
                                "period": 30,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "totp",
                            "uuid": "71789cdc-d0be-42ad-98ab-ea146c5ea5d6",
                            "name": "user2+totp@test.com",
                            "issuer": "AWS",
                            "icon": nil,
                            "info": [
                                "secret": "U7WXBPTLK62EC6Y2X4ALCMWWHS",
                                "algo": "SHA256",
                                "digits": 7,
                                "period": 60,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "totp",
                            "uuid": "f98fdeef-03ef-4491-b408-2ecfa4f20ad4",
                            "name": "user3+totp@test.com",
                            "issuer": "PG",
                            "icon": nil,
                            "info": [
                                "secret": "V27AJDJS4HZM3CTQNZXLVCHJYE",
                                "algo": "SHA512",
                                "digits": 8,
                                "period": 50,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "totp",
                            "uuid": "2b2ba134-870d-4100-91f6-1193ad569841",
                            "name": "",
                            "issuer": "",
                            "icon": nil,
                            "info": [
                                "secret": "MGTMWSHCBRMOBRI2AXNJD4M332",
                                "algo": "SHA1",
                                "digits": 6,
                                "period": 30,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "hotp",
                            "uuid": "256f1470-2ece-47c6-a763-235a56167d6a",
                            "name": "user1+hotp@test.com",
                            "issuer": "Yubi",
                            "icon": nil,
                            "info": [
                                "secret": "KXXYUNPQY2CDRBDFLAIIEQ4H7O",
                                "algo": "SHA1",
                                "digits": 6,
                                "counter": 1,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "hotp",
                            "uuid": "ebc55e92-24f6-4ddd-81d0-1e293549ad41",
                            "name": "user2+hotp@test.com",
                            "issuer": "Hene",
                            "icon": nil,
                            "info": [
                                "secret": "LI3SJSNME7PSCQCXL2TIFMNH64",
                                "algo": "SHA256",
                                "digits": 7,
                                "counter": 16,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "hotp",
                            "uuid": "9c4d30ba-3c19-46d7-929a-7eb01e1956af",
                            "name": "user3+hotp@test.com",
                            "issuer": "Nath",
                            "icon": nil,
                            "info": [
                                "secret": "F7E5IPN2KYUXE5WZLMSRVTFK7N",
                                "algo": "SHA512",
                                "digits": 8,
                                "counter": 101,
                            ],
                        ],
                        [
                            "favorite": false,
                            "groups": [],
                            "note": "",
                            "type": "hotp",
                            "uuid": "3cb83fc3-8e25-4df5-bdde-1f35611c1d0a",
                            "name": "",
                            "issuer": "",
                            "icon": nil,
                            "info": [
                                "secret": "KQOZTMLOJBSMYWIO4BG4UTXDSR",
                                "algo": "SHA1",
                                "digits": 6,
                                "counter": 22,
                            ],
                        ],
                    ],
                ],
            ]

        let importService = ImportService()
        let tokens = importService.importFromAegis(json: json)!

        XCTAssertEqual(tokens.count, 6)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Apple")
        XCTAssertEqual(tokens[0].account, "user1+totp@test.com")
        XCTAssertEqual(tokens[0].period, 30)
        XCTAssertEqual(tokens[0].secret, "AB6B7FAYHW2G42ZA4FJHLRWWHU")

        XCTAssertEqual(tokens[1].digits, 7)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[1].issuer, "AWS")
        XCTAssertEqual(tokens[1].account, "user2+totp@test.com")
        XCTAssertEqual(tokens[1].period, 60)
        XCTAssertEqual(tokens[1].secret, "U7WXBPTLK62EC6Y2X4ALCMWWHS")

        XCTAssertEqual(tokens[2].digits, 8)
        XCTAssertEqual(tokens[2].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[2].algorithm, TokenAlgorithmEnum.SHA512)
        XCTAssertEqual(tokens[2].issuer, "PG")
        XCTAssertEqual(tokens[2].account, "user3+totp@test.com")
        XCTAssertEqual(tokens[2].period, 50)
        XCTAssertEqual(tokens[2].secret, "V27AJDJS4HZM3CTQNZXLVCHJYE")

        XCTAssertEqual(tokens[3].digits, 6)
        XCTAssertEqual(tokens[3].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[3].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[3].issuer, "")
        XCTAssertEqual(tokens[3].account, "")
        XCTAssertEqual(tokens[3].period, 30)
        XCTAssertEqual(tokens[3].secret, "MGTMWSHCBRMOBRI2AXNJD4M332")

        XCTAssertEqual(tokens[4].digits, 6)
        XCTAssertEqual(tokens[4].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[4].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[4].issuer, "Yubi")
        XCTAssertEqual(tokens[4].account, "user1+hotp@test.com")
        XCTAssertEqual(tokens[4].counter, 1)
        XCTAssertEqual(tokens[4].secret, "KXXYUNPQY2CDRBDFLAIIEQ4H7O")

        XCTAssertEqual(tokens[5].digits, 7)
        XCTAssertEqual(tokens[5].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[5].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[5].issuer, "Hene")
        XCTAssertEqual(tokens[5].account, "user2+hotp@test.com")
        XCTAssertEqual(tokens[5].counter, 16)
        XCTAssertEqual(tokens[5].secret, "LI3SJSNME7PSCQCXL2TIFMNH64")

        XCTAssertEqual(tokens[6].digits, 8)
        XCTAssertEqual(tokens[6].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[6].algorithm, TokenAlgorithmEnum.SHA512)
        XCTAssertEqual(tokens[6].issuer, "Nath")
        XCTAssertEqual(tokens[6].account, "user3+hotp@test.com")
        XCTAssertEqual(tokens[6].counter, 101)
        XCTAssertEqual(tokens[6].secret, "F7E5IPN2KYUXE5WZLMSRVTFK7N")

        XCTAssertEqual(tokens[7].digits, 6)
        XCTAssertEqual(tokens[7].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[7].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[7].issuer, "")
        XCTAssertEqual(tokens[7].account, "")
        XCTAssertEqual(tokens[7].counter, 22)
        XCTAssertEqual(tokens[7].secret, "KQOZTMLOJBSMYWIO4BG4UTXDSR")
    }
}
