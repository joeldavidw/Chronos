@testable import Chronos
import XCTest

final class ParseOtpAuthUrlTests: XCTestCase {
    func testTotp() throws {
        let otpService = OTPService()

        // Test case 1: Standard TOTP token
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/Apple:john@appleseed.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=Apple&period=30")
            XCTAssertEqual(token.issuer, "Apple")
            XCTAssertEqual(token.account, "john@appleseed.com")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 2: TOTP token without account
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=Apple&period=30")
            XCTAssertEqual(token.issuer, "Apple")
            XCTAssertEqual(token.account, "")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 3: TOTP token with different period and algorithm
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/Apple:john@appleseed.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=7&issuer=Apple&period=45")
            XCTAssertEqual(token.issuer, "Apple")
            XCTAssertEqual(token.account, "john@appleseed.com")
            XCTAssertEqual(token.period, 45)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 7)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA256)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 4: TOTP token without issuer
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/john@doe.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&period=30")
            XCTAssertEqual(token.issuer, "")
            XCTAssertEqual(token.account, "john@doe.com")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 5: TOTP token with special characters in account and issuer
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/My%20Company:john.doe+test@mycompany.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=My%20Company&period=30")
            XCTAssertEqual(token.issuer, "My Company")
            XCTAssertEqual(token.account, "john.doe+test@mycompany.com")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 6: TOTP token with no issuer and no account
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&period=30")
            XCTAssertEqual(token.issuer, "")
            XCTAssertEqual(token.account, "")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 7: TOTP token with different digits and SHA512 algorithm
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/Google:alice@google.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512&digits=8&issuer=Google&period=60")
            XCTAssertEqual(token.issuer, "Google")
            XCTAssertEqual(token.account, "alice@google.com")
            XCTAssertEqual(token.period, 60)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 8)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA512)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }

        // Test case 8: TOTP token with empty secret
        do {
            _ = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/Example:user@example.com?secret=&algorithm=SHA1&digits=6&issuer=Example&period=30")
            XCTFail("Expected OTPError.invalidSecret but no error was thrown")
        } catch OTPError.invalidSecret {
            // Success: expected error was thrown
        } catch {
            XCTFail("Expected OTPError.invalidSecret but a different error was thrown")
        }

        // Test case 9: Standard TOTP token with lowercase algorithm
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=sha1&digits=6&issuer=GitHub&period=30")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 10: Standard TOTP token with lowercase algorithm non default
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=sha256&digits=6&issuer=GitHub&period=30")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA256)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }
    }

    func testHotp() throws {
        let otpService = OTPService()

        // Test case 1: Standard HOTP token
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=GitHub&counter=1")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 2: HOTP token without account
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/GitHub:?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=GitHub&counter=1")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 3: HOTP token with different counter and algorithm
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=7&issuer=GitHub&counter=10")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.counter, 10)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 7)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA256)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 4: HOTP token without issuer
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&counter=1")
            XCTAssertEqual(token.issuer, "")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 5: HOTP token with special characters in account and issuer
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/My%20Company:user+test@mycompany.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=My%20Company&counter=1")
            XCTAssertEqual(token.issuer, "My Company")
            XCTAssertEqual(token.account, "user+test@mycompany.com")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 6: HOTP token with no issuer and no account
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&counter=1")
            XCTAssertEqual(token.issuer, "")
            XCTAssertEqual(token.account, "")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 7: HOTP token with different digits and SHA512 algorithm
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/Google:user@google.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512&digits=8&issuer=Google&counter=100")
            XCTAssertEqual(token.issuer, "Google")
            XCTAssertEqual(token.account, "user@google.com")
            XCTAssertEqual(token.counter, 100)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 8)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA512)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 8: HOTP token with empty secret
        do {
            _ = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/Example:user@example.com?secret=&algorithm=SHA1&digits=6&issuer=Example&counter=1")
            XCTFail("Expected OTPError.invalidSecret but no error was thrown")
        } catch OTPError.invalidSecret {
            // Success: expected error was thrown
        } catch {
            XCTFail("Expected OTPError.invalidSecret but a different error was thrown")
        }

        // Test case 9: Standard HOTP token with lowercase algorithm
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=sha1&digits=6&issuer=GitHub&counter=1")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }

        // Test case 10: Standard HOTP token with lowercase algorithm non default
        do {
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=sha256&digits=6&issuer=GitHub&counter=1")
            XCTAssertEqual(token.issuer, "GitHub")
            XCTAssertEqual(token.account, "user@github.com")
            XCTAssertEqual(token.counter, 1)
            XCTAssertEqual(token.secret, "JBSWY3DPEHPK3PXP")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.HOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA256)
        } catch {
            XCTFail("Parsing HOTP URL failed")
        }
    }
}
