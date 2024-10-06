@testable import Chronos
import XCTest

class TokenValidatorTests: XCTestCase {
    // Helper function to create a valid base32 secret
    private func validBase32Secret() -> String {
        return "JBSWY3DPEHPK3PXP" // A valid base32 encoded string
    }

    // Test valid TOTP token
    func testValidTOTPToken() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = 6
        token.period = 30

        XCTAssertNoThrow(try TokenValidator.validate(token: token))
    }

    // Test valid HOTP token
    func testValidHOTPToken() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .HOTP
        token.digits = 6
        token.counter = 1

        XCTAssertNoThrow(try TokenValidator.validate(token: token))
    }

    // Test empty secret
    func testEmptySecret() {
        let token = Token()
        token.secret = ""
        token.type = .TOTP

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidSecret("Secret cannot be empty."))
        }
    }

    // Test invalid (non-base32) secret
    func testInvalidSecret() {
        let token = Token()
        token.secret = "INVALID_SECRET"
        token.type = .TOTP

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidSecret("Secret is not base32 encoded."))
        }
    }

    // Test invalid digits (not in the range of 6-8)
    func testInvalidDigitsUpper() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = 9

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidDigits(9))
        }
    }

    func testInvalidDigitsLower() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = 5

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidDigits(5))
        }
    }

    func testInvalidDigitsZero() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = 0

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidDigits(0))
        }
    }

    func testInvalidDigitsNegative() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = -10

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidDigits(-10))
        }
    }

    // Test negative counter for HOTP token
    func testNegativeCounterForHOTP() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .HOTP
        token.digits = 6
        token.counter = -1

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidCounter(-1))
        }
    }

    // Test invalid period for TOTP token (must be greater than 0)
    func testInvalidPeriodForTOTP() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = 6
        token.period = 0

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidPeriod(0))
        }
    }

    func testInvalidPeriodForTOTPNegative() {
        let token = Token()
        token.secret = validBase32Secret()
        token.type = .TOTP
        token.digits = 6
        token.period = -10

        XCTAssertThrowsError(try TokenValidator.validate(token: token)) { error in
            XCTAssertEqual(error as? TokenError, TokenError.invalidPeriod(-10))
        }
    }
}
