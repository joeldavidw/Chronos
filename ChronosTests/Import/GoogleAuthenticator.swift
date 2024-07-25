@testable import Chronos
import SwiftyJSON
import XCTest

final class GoogleAuthenticatorTests: XCTestCase {
    func testValidImport() throws {
        let authOtpMigratation = "otpauth-migration://offline?data=Ci0KCkhlbGxvId6tvu8SEmpvaG5AYXBwbGVzZWVkLmNvbRoFQXBwbGUgASgBMAIKLgoKSGVsbG8h3q2%2B7xITam9objJAYXBwbGVzZWVkLmNvbRoFQXBwbGUgAigCMAIKNAoKSGVsbG8h3q2%2B7xIXam9obitob3RwQGFwcGxlc2VlZC5jb20aBUFwcGxlIAEoATABOAAKNQoKSGVsbG8h3q2%2B7xIYam9obitob3RwMkBhcHBsZXNlZWQuY29tGgVBcHBsZSABKAIwATgAEAIYASAA"

        let importService = ImportService()
        let tokens = importService.importFromGoogleAuth(otpAuthMigration: authOtpMigratation)!

        XCTAssertEqual(tokens.count, 4)

        XCTAssertEqual(tokens[0].digits, 6)
        XCTAssertEqual(tokens[0].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[0].counter, 0)
        XCTAssertEqual(tokens[0].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[0].issuer, "Apple")
        XCTAssertEqual(tokens[0].account, "john@appleseed.com")
        XCTAssertEqual(tokens[0].period, 30)
        XCTAssertEqual(tokens[0].secret, "JBSWY3DPEHPK3PXP")

        XCTAssertEqual(tokens[1].digits, 8)
        XCTAssertEqual(tokens[1].type, TokenTypeEnum.TOTP)
        XCTAssertEqual(tokens[1].counter, 0)
        XCTAssertEqual(tokens[1].algorithm, TokenAlgorithmEnum.SHA256)
        XCTAssertEqual(tokens[1].issuer, "Apple")
        XCTAssertEqual(tokens[1].account, "john2@appleseed.com")
        XCTAssertEqual(tokens[1].period, 30)
        XCTAssertEqual(tokens[1].secret, "JBSWY3DPEHPK3PXP")

        XCTAssertEqual(tokens[2].digits, 6)
        XCTAssertEqual(tokens[2].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[2].counter, 0)
        XCTAssertEqual(tokens[2].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[2].issuer, "Apple")
        XCTAssertEqual(tokens[2].account, "john+hotp@appleseed.com")
        XCTAssertEqual(tokens[2].counter, 0)
        XCTAssertEqual(tokens[2].secret, "JBSWY3DPEHPK3PXP")

        XCTAssertEqual(tokens[3].digits, 8)
        XCTAssertEqual(tokens[3].type, TokenTypeEnum.HOTP)
        XCTAssertEqual(tokens[3].counter, 0)
        XCTAssertEqual(tokens[3].algorithm, TokenAlgorithmEnum.SHA1)
        XCTAssertEqual(tokens[3].issuer, "Apple")
        XCTAssertEqual(tokens[3].account, "john+hotp2@appleseed.com")
        XCTAssertEqual(tokens[3].counter, 0)
        XCTAssertEqual(tokens[3].secret, "JBSWY3DPEHPK3PXP")
    }

    func testInvalidImport_AlgoMD5() throws {
        let authOtpMigratation = "otpauth-migration://offline?data=Ci0KCkhlbGxvId6tvu8SEmpvaG5AYXBwbGVzZWVkLmNvbRoFQXBwbGUgASgBMAIKLgoKSGVsbG8h3q2%2B6RIRbWQ1QGFwcGxlc2VlZC5jb20aBUFwcGxlIAQoATABOAAQAhgBIAA%3D"

        let importService = ImportService()
        let tokens = importService.importFromGoogleAuth(otpAuthMigration: authOtpMigratation)

        XCTAssertNil(tokens, "Should fail fast if any tokens contains md5 algo")
    }
}
