@testable import Chronos
import XCTest

final class EnteTests: XCTestCase {
    func testValidImport() throws {
        let inputData = """
        otpauth://totp/Apple:user1+totp@test.com?secret=AB6B7FAYHW2G42ZA4FJHLRWWHU&issuer=Apple&algorithm=SHA1&digits=6&period=30
        otpauth://totp/AWS:user2+totp@test.com?secret=U7WXBPTLK62EC6Y2X4ALCMWWHS&issuer=AWS&algorithm=SHA256&digits=7&period=60
        otpauth://totp/PG:user3+totp@test.com?secret=V27AJDJS4HZM3CTQNZXLVCHJYE&issuer=PG&algorithm=SHA512&digits=8&period=50
        otpauth://totp/:?secret=MGTMWSHCBRMOBRI2AXNJD4M332&issuer=&algorithm=SHA1&digits=6&period=30
        """

        let importService = ImportService()
        let tokens = importService.importFromEnte(enteText: inputData)!

        XCTAssertEqual(tokens.count, 4)

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
    }

    func testValidImport_Whitepsaces() throws {
        let inputData = """


        otpauth://totp/Apple:user1+totp@test.com?secret=AB6B7FAYHW2G42ZA4FJHLRWWHU&issuer=Apple&algorithm=SHA1&digits=6&period=30

        otpauth://totp/AWS:user2+totp@test.com?secret=U7WXBPTLK62EC6Y2X4ALCMWWHS&issuer=AWS&algorithm=SHA256&digits=7&period=60


        otpauth://totp/PG:user3+totp@test.com?secret=V27AJDJS4HZM3CTQNZXLVCHJYE&issuer=PG&algorithm=SHA512&digits=8&period=50

        otpauth://totp/:?secret=MGTMWSHCBRMOBRI2AXNJD4M332&issuer=&algorithm=SHA1&digits=6&period=30



        """

        let importService = ImportService()
        let tokens = importService.importFromEnte(enteText: inputData)!

        XCTAssertEqual(tokens.count, 4)
    }
}
