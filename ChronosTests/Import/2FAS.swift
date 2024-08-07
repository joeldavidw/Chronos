@testable import Chronos
import SwiftyJSON
import XCTest

final class TwoFASTests: XCTestCase {
    func testValidImport() throws {
        let json: JSON =
            [
                "appOrigin": "ios",
                "appVersionCode": 50308,
                "appVersionName": "5.3.8",
                "groups": [],
                "schemaVersion": 4,
                "services": [
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "90CAF674-4269-4193-9749-4849F97CFB53",
                            ],
                            "label": [
                                "backgroundColor": "Orange",
                                "text": "AP",
                            ],
                            "selected": "IconCollection",
                        ],
                        "name": "Apple",
                        "order": [
                            "position": 0,
                        ],
                        "otp": [
                            "account": "user1+totp@test.com",
                            "algorithm": "SHA1",
                            "counter": 0,
                            "digits": 6,
                            "issuer": "Apple",
                            "period": 30,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "AB6B7FAYHW2G42ZA4FJHLRWWHU",
                        "serviceTypeID": "ea250427-4465-48d7-bbcd-4616be85626a",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Brown",
                                "text": "AW",
                            ],
                            "selected": "Label",
                        ],
                        "name": "AWS",
                        "order": [
                            "position": 1,
                        ],
                        "otp": [
                            "account": "user2+totp@test.com",
                            "algorithm": "SHA256",
                            "counter": 0,
                            "digits": 7,
                            "issuer": "AWS",
                            "period": 60,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "U7WXBPTLK62EC6Y2X4ALCMWWHS",
                        "serviceTypeID": "71789cdc-d0be-42ad-98ab-ea146c5ea5d6",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Indigo",
                                "text": "PG",
                            ],
                            "selected": "Label",
                        ],
                        "name": "PG",
                        "order": [
                            "position": 2,
                        ],
                        "otp": [
                            "account": "user3+totp@test.com",
                            "algorithm": "SHA512",
                            "counter": 0,
                            "digits": 8,
                            "issuer": "PG",
                            "period": 50,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "V27AJDJS4HZM3CTQNZXLVCHJYE",
                        "serviceTypeID": "f98fdeef-03ef-4491-b408-2ecfa4f20ad4",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Gray",
                                "text": "UN",
                            ],
                            "selected": "Label",
                        ],
                        "name": "Unknown",
                        "order": [
                            "position": 3,
                        ],
                        "otp": [
                            "account": "",
                            "algorithm": "SHA1",
                            "counter": 0,
                            "digits": 6,
                            "issuer": "",
                            "period": 30,
                            "source": "manual",
                            "tokenType": "TOTP",
                        ],
                        "secret": "MGTMWSHCBRMOBRI2AXNJD4M332",
                        "serviceTypeID": "2b2ba134-870d-4100-91f6-1193ad569841",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "90CAF674-4269-4193-9749-4849F97CFB53",
                            ],
                            "label": [
                                "backgroundColor": "Yellow",
                                "text": "YU",
                            ],
                            "selected": "IconCollection",
                        ],
                        "name": "Yubi",
                        "order": [
                            "position": 4,
                        ],
                        "otp": [
                            "account": "user1+hotp@test.com",
                            "algorithm": "SHA1",
                            "counter": 1,
                            "digits": 6,
                            "issuer": "Yubi",
                            "period": 0,
                            "source": "link",
                            "tokenType": "HOTP",
                        ],
                        "secret": "KXXYUNPQY2CDRBDFLAIIEQ4H7O",
                        "serviceTypeID": "256f1470-2ece-47c6-a763-235a56167d6a",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Red",
                                "text": "HE",
                            ],
                            "selected": "Label",
                        ],
                        "name": "Hene",
                        "order": [
                            "position": 5,
                        ],
                        "otp": [
                            "account": "user2+hotp@test.com",
                            "algorithm": "SHA256",
                            "counter": 16,
                            "digits": 7,
                            "issuer": "Hene",
                            "period": 0,
                            "source": "link",
                            "tokenType": "HOTP",
                        ],
                        "secret": "LI3SJSNME7PSCQCXL2TIFMNH64",
                        "serviceTypeID": "ebc55e92-24f6-4ddd-81d0-1e293549ad41",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Blue",
                                "text": "NA",
                            ],
                            "selected": "Label",
                        ],
                        "name": "Nath",
                        "order": [
                            "position": 6,
                        ],
                        "otp": [
                            "account": "user3+hotp@test.com",
                            "algorithm": "SHA512",
                            "counter": 101,
                            "digits": 8,
                            "issuer": "Nath",
                            "period": 0,
                            "source": "link",
                            "tokenType": "HOTP",
                        ],
                        "secret": "F7E5IPN2KYUXE5WZLMSRVTFK7N",
                        "serviceTypeID": "9c4d30ba-3c19-46d7-929a-7eb01e1956af",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Green",
                                "text": "UN",
                            ],
                            "selected": "Label",
                        ],
                        "name": "Unknown",
                        "order": [
                            "position": 7,
                        ],
                        "otp": [
                            "account": "",
                            "algorithm": "SHA1",
                            "counter": 22,
                            "digits": 6,
                            "issuer": "",
                            "period": 0,
                            "source": "manual",
                            "tokenType": "HOTP",
                        ],
                        "secret": "KQOZTMLOJBSMYWIO4BG4UTXDSR",
                        "serviceTypeID": "3cb83fc3-8e25-4df5-bdde-1f35611c1d0a",
                        "updatedAt": 1_721_919_046_000,
                    ],
                ],
            ]

        let importService = ImportService()
        let tokens = importService.importFrom2FAS(json: json)!

        XCTAssertEqual(tokens.count, 8)

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

    func testValidImport_Period() throws {
        let json: JSON =
            [
                "appOrigin": "ios",
                "appVersionCode": 50308,
                "appVersionName": "5.3.8",
                "groups": [],
                "schemaVersion": 4,
                "services": [
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "90CAF674-4269-4193-9749-4849F97CFB53",
                            ],
                            "label": [
                                "backgroundColor": "Orange",
                                "text": "AP",
                            ],
                            "selected": "IconCollection",
                        ],
                        "name": "Apple",
                        "order": [
                            "position": 0,
                        ],
                        "otp": [
                            "account": "user1+totp@test.com",
                            "algorithm": "SHA1",
                            "counter": 0,
                            "digits": 6,
                            "issuer": "Apple",
                            "period": 10,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "AB6B7FAYHW2G42ZA4FJHLRWWHU",
                        "serviceTypeID": "ea250427-4465-48d7-bbcd-4616be85626a",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Brown",
                                "text": "AW",
                            ],
                            "selected": "Label",
                        ],
                        "name": "AWS",
                        "order": [
                            "position": 1,
                        ],
                        "otp": [
                            "account": "user2+totp@test.com",
                            "algorithm": "SHA256",
                            "counter": 0,
                            "digits": 7,
                            "issuer": "AWS",
                            "period": 30,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "U7WXBPTLK62EC6Y2X4ALCMWWHS",
                        "serviceTypeID": "71789cdc-d0be-42ad-98ab-ea146c5ea5d6",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Indigo",
                                "text": "PG",
                            ],
                            "selected": "Label",
                        ],
                        "name": "PG",
                        "order": [
                            "position": 2,
                        ],
                        "otp": [
                            "account": "user3+totp@test.com",
                            "algorithm": "SHA512",
                            "counter": 0,
                            "digits": 8,
                            "issuer": "PG",
                            "period": 60,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "V27AJDJS4HZM3CTQNZXLVCHJYE",
                        "serviceTypeID": "f98fdeef-03ef-4491-b408-2ecfa4f20ad4",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Gray",
                                "text": "UN",
                            ],
                            "selected": "Label",
                        ],
                        "name": "Unknown",
                        "order": [
                            "position": 3,
                        ],
                        "otp": [
                            "account": "",
                            "algorithm": "SHA1",
                            "counter": 0,
                            "digits": 6,
                            "issuer": "",
                            "period": 90,
                            "source": "manual",
                            "tokenType": "TOTP",
                        ],
                        "secret": "MGTMWSHCBRMOBRI2AXNJD4M332",
                        "serviceTypeID": "2b2ba134-870d-4100-91f6-1193ad569841",
                        "updatedAt": 1_721_919_046_000,
                    ],
                ],
            ]

        let importService = ImportService()
        let tokens = importService.importFrom2FAS(json: json)!

        XCTAssertEqual(tokens.count, 4)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Apple")
        XCTAssertEqual(tokens[0].account, "user1+totp@test.com")
        XCTAssertEqual(tokens[0].period, 10)
        XCTAssertEqual(tokens[0].secret, "AB6B7FAYHW2G42ZA4FJHLRWWHU")

        XCTAssertEqual(tokens[1].digits, 7)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[1].issuer, "AWS")
        XCTAssertEqual(tokens[1].account, "user2+totp@test.com")
        XCTAssertEqual(tokens[1].period, 30)
        XCTAssertEqual(tokens[1].secret, "U7WXBPTLK62EC6Y2X4ALCMWWHS")

        XCTAssertEqual(tokens[2].digits, 8)
        XCTAssertEqual(tokens[2].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[2].algorithm, TokenAlgorithmEnum.SHA512)
        XCTAssertEqual(tokens[2].issuer, "PG")
        XCTAssertEqual(tokens[2].account, "user3+totp@test.com")
        XCTAssertEqual(tokens[2].period, 60)
        XCTAssertEqual(tokens[2].secret, "V27AJDJS4HZM3CTQNZXLVCHJYE")

        XCTAssertEqual(tokens[3].digits, 6)
        XCTAssertEqual(tokens[3].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[3].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[3].issuer, "")
        XCTAssertEqual(tokens[3].account, "")
        XCTAssertEqual(tokens[3].period, 90)
        XCTAssertEqual(tokens[3].secret, "MGTMWSHCBRMOBRI2AXNJD4M332")
    }

    func testInvalidImport_Algorithm() throws {
        let json: JSON =
            [
                "appOrigin": "ios",
                "appVersionCode": 50308,
                "appVersionName": "5.3.8",
                "groups": [],
                "schemaVersion": 4,
                "services": [
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "90CAF674-4269-4193-9749-4849F97CFB53",
                            ],
                            "label": [
                                "backgroundColor": "Orange",
                                "text": "AP",
                            ],
                            "selected": "IconCollection",
                        ],
                        "name": "Apple",
                        "order": [
                            "position": 0,
                        ],
                        "otp": [
                            "account": "user1+totp@test.com",
                            "algorithm": "SHA1",
                            "counter": 0,
                            "digits": 6,
                            "issuer": "Apple",
                            "period": 30,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "AB6B7FAYHW2G42ZA4FJHLRWWHU",
                        "serviceTypeID": "ea250427-4465-48d7-bbcd-4616be85626a",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Brown",
                                "text": "AW",
                            ],
                            "selected": "Label",
                        ],
                        "name": "AWS",
                        "order": [
                            "position": 1,
                        ],
                        "otp": [
                            "account": "userMD5+totp@test.com",
                            "algorithm": "MD5",
                            "counter": 0,
                            "digits": 7,
                            "issuer": "AWS",
                            "period": 60,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "U7WXBPTLK62EC6Y2X4ALCMWWHS",
                        "serviceTypeID": "71789cdc-d0be-42ad-98ab-ea146c5ea5d6",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Indigo",
                                "text": "PG",
                            ],
                            "selected": "Label",
                        ],
                        "name": "PG",
                        "order": [
                            "position": 2,
                        ],
                        "otp": [
                            "account": "userSHA224@test.com",
                            "algorithm": "SHA224",
                            "counter": 0,
                            "digits": 8,
                            "issuer": "PG",
                            "period": 30,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "V27AJDJS4HZM3CTQNZXLVCHJYE",
                        "serviceTypeID": "f98fdeef-03ef-4491-b408-2ecfa4f20ad4",
                        "updatedAt": 1_721_919_046_000,
                    ],
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "A5B3FB65-4EC5-43E6-8EC1-49E24CA9E7AD",
                            ],
                            "label": [
                                "backgroundColor": "Indigo",
                                "text": "PG",
                            ],
                            "selected": "Label",
                        ],
                        "name": "PG",
                        "order": [
                            "position": 2,
                        ],
                        "otp": [
                            "account": "userSHA334@test.com",
                            "algorithm": "SHA334",
                            "counter": 0,
                            "digits": 8,
                            "issuer": "PG",
                            "period": 30,
                            "source": "link",
                            "tokenType": "TOTP",
                        ],
                        "secret": "V27AJDJS4HZM3CTQNZXLVCHJYE",
                        "serviceTypeID": "f98fdeef-03ef-4491-b408-2ecfa4f20ad4",
                        "updatedAt": 1_721_919_046_000,
                    ],
                ],
            ]

        let importService = ImportService()
        let tokens = importService.importFrom2FAS(json: json)

        XCTAssertNil(tokens)
    }

    func testInvalidImport_Steam() throws {
        let json: JSON =
            [
                "appOrigin": "ios",
                "appVersionCode": 50308,
                "appVersionName": "5.3.8",
                "groups": [],
                "schemaVersion": 4,
                "services": [
                    [
                        "icon": [
                            "iconCollection": [
                                "id": "90CAF674-4269-4193-9749-4849F97CFB53",
                            ],
                            "label": [
                                "backgroundColor": "Orange",
                                "text": "AP",
                            ],
                            "selected": "IconCollection",
                        ],
                        "name": "Apple",
                        "order": [
                            "position": 0,
                        ],
                        "otp": [
                            "account": "user1+totp@test.com",
                            "algorithm": "SHA1",
                            "counter": 0,
                            "digits": 6,
                            "issuer": "Apple",
                            "period": 30,
                            "source": "link",
                            "tokenType": "STEAM",
                        ],
                        "secret": "AB6B7FAYHW2G42ZA4FJHLRWWHU",
                        "serviceTypeID": "ea250427-4465-48d7-bbcd-4616be85626a",
                        "updatedAt": 1_721_919_046_000,
                    ],
                ],
            ]

        let importService = ImportService()
        let tokens = importService.importFrom2FAS(json: json)

        XCTAssertNil(tokens)
    }
}
