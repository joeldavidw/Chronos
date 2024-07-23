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
            let token = try otpService.parseOtpAuthUrl(otpAuthStr: "otpauth://totp/Example:user@example.com?secret=&algorithm=SHA1&digits=6&issuer=Example&period=30")
            XCTAssertEqual(token.issuer, "Example")
            XCTAssertEqual(token.account, "user@example.com")
            XCTAssertEqual(token.period, 30)
            XCTAssertEqual(token.secret, "")
            XCTAssertEqual(token.digits, 6)
            XCTAssertEqual(token.type, TokenTypeEnum.TOTP)
            XCTAssertEqual(token.algorithm, TokenAlgorithmEnum.SHA1)
        } catch {
            XCTFail("Parsing TOTP URL failed")
        }
    }

    func testHotp() throws {
        let otpService = OTPService()

        // Test case 1: Standard HOTP token
        let token1 = Token()
        token1.issuer = "GitHub"
        token1.account = "user@github.com"
        token1.counter = 1
        token1.secret = "JBSWY3DPEHPK3PXP"
        token1.digits = 6
        token1.type = TokenTypeEnum.HOTP
        token1.algorithm = TokenAlgorithmEnum.SHA1

        var url = otpService.tokenToOtpAuthUrl(token: token1)!
        XCTAssertEqual(url, "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=GitHub&counter=1")

        // Test case 2: HOTP token without account
        let token2 = Token()
        token2.issuer = "GitHub"
        token2.counter = 1
        token2.secret = "JBSWY3DPEHPK3PXP"
        token2.digits = 6
        token2.type = TokenTypeEnum.HOTP
        token2.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token2)!
        XCTAssertEqual(url, "otpauth://hotp/GitHub:?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=GitHub&counter=1")

        // Test case 3: HOTP token with different counter and algorithm
        let token3 = Token()
        token3.issuer = "GitHub"
        token3.account = "user@github.com"
        token3.counter = 10
        token3.secret = "JBSWY3DPEHPK3PXP"
        token3.digits = 7
        token3.type = TokenTypeEnum.HOTP
        token3.algorithm = TokenAlgorithmEnum.SHA256

        url = otpService.tokenToOtpAuthUrl(token: token3)!
        XCTAssertEqual(url, "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=7&issuer=GitHub&counter=10")

        // Test case 4: HOTP token without issuer
        let token4 = Token()
        token4.account = "user@github.com"
        token4.counter = 1
        token4.secret = "JBSWY3DPEHPK3PXP"
        token4.digits = 6
        token4.type = TokenTypeEnum.HOTP
        token4.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token4)!
        XCTAssertEqual(url, "otpauth://hotp/user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&counter=1")

        // Test case 5: HOTP token with special characters in account and issuer
        let token5 = Token()
        token5.issuer = "My Company"
        token5.account = "user+test@mycompany.com"
        token5.counter = 1
        token5.secret = "JBSWY3DPEHPK3PXP"
        token5.digits = 6
        token5.type = TokenTypeEnum.HOTP
        token5.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token5)!
        XCTAssertEqual(url, "otpauth://hotp/My%20Company:user+test@mycompany.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=My%20Company&counter=1")

        // Test case 6: HOTP token with no issuer and no account
        let token6 = Token()
        token6.counter = 1
        token6.secret = "JBSWY3DPEHPK3PXP"
        token6.digits = 6
        token6.type = TokenTypeEnum.HOTP
        token6.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token6)!
        XCTAssertEqual(url, "otpauth://hotp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&counter=1")

        // Test case 7: HOTP token with different digits and SHA512 algorithm
        let token7 = Token()
        token7.issuer = "Google"
        token7.account = "user@google.com"
        token7.counter = 100
        token7.secret = "JBSWY3DPEHPK3PXP"
        token7.digits = 8
        token7.type = TokenTypeEnum.HOTP
        token7.algorithm = TokenAlgorithmEnum.SHA512

        url = otpService.tokenToOtpAuthUrl(token: token7)!
        XCTAssertEqual(url, "otpauth://hotp/Google:user@google.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512&digits=8&issuer=Google&counter=100")

        // Test case 8: HOTP token with empty secret
        let token8 = Token()
        token8.issuer = "Example"
        token8.account = "user@example.com"
        token8.counter = 1
        token8.secret = ""
        token8.digits = 6
        token8.type = TokenTypeEnum.HOTP
        token8.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token8)!
        XCTAssertEqual(url, "otpauth://hotp/Example:user@example.com?secret=&algorithm=SHA1&digits=6&issuer=Example&counter=1")
    }
}
