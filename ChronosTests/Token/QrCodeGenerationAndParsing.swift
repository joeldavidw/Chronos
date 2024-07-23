@testable import Chronos
import EFQRCode
import Vision
import XCTest

final class QrCodeGenerationAndParsingTests: XCTestCase {
    func testTotp() throws {
        let otpService = OTPService()

        // Test case 1: Standard TOTP token
        let token1 = Token()
        token1.issuer = "Apple"
        token1.account = "john@appleseed.com"
        token1.period = 30
        token1.secret = "JBSWY3DPEHPK3PXP"
        token1.digits = 6
        token1.type = TokenTypeEnum.TOTP
        token1.algorithm = TokenAlgorithmEnum.SHA1

        var url = otpService.tokenToOtpAuthUrl(token: token1)!
        let qr1 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr1!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/Apple:john@appleseed.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=Apple&period=30")
        }

        // Test case 2: TOTP token without account
        let token2 = Token()
        token2.issuer = "Apple"
        token2.period = 30
        token2.secret = "JBSWY3DPEHPK3PXP"
        token2.digits = 6
        token2.type = TokenTypeEnum.TOTP
        token2.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token2)!
        let qr2 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr2!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=Apple&period=30")
        }

        // Test case 3: TOTP token with different period and algorithm
        let token3 = Token()
        token3.issuer = "Apple"
        token3.account = "john@appleseed.com"
        token3.period = 45
        token3.secret = "JBSWY3DPEHPK3PXP"
        token3.digits = 7
        token3.type = TokenTypeEnum.TOTP
        token3.algorithm = TokenAlgorithmEnum.SHA256

        url = otpService.tokenToOtpAuthUrl(token: token3)!
        let qr3 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr3!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/Apple:john@appleseed.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=7&issuer=Apple&period=45")
        }

        // Test case 4: TOTP token without issuer
        let token4 = Token()
        token4.account = "john@doe.com"
        token4.period = 30
        token4.secret = "JBSWY3DPEHPK3PXP"
        token4.digits = 6
        token4.type = TokenTypeEnum.TOTP
        token4.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token4)!
        let qr4 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr4!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/john@doe.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&period=30")
        }

        // Test case 5: TOTP token with special characters in account and issuer
        let token5 = Token()
        token5.issuer = "My Company"
        token5.account = "john.doe+test@mycompany.com"
        token5.period = 30
        token5.secret = "JBSWY3DPEHPK3PXP"
        token5.digits = 6
        token5.type = TokenTypeEnum.TOTP
        token5.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token5)!
        let qr5 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr5!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/My%20Company:john.doe+test@mycompany.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=My%20Company&period=30")
        }

        // Test case 6: TOTP token with no issuer and no account
        let token6 = Token()
        token6.period = 30
        token6.secret = "JBSWY3DPEHPK3PXP"
        token6.digits = 6
        token6.type = TokenTypeEnum.TOTP
        token6.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token6)!
        let qr6 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr6!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&period=30")
        }

        // Test case 7: TOTP token with different digits and SHA512 algorithm
        let token7 = Token()
        token7.issuer = "Google"
        token7.account = "alice@google.com"
        token7.period = 60
        token7.secret = "JBSWY3DPEHPK3PXP"
        token7.digits = 8
        token7.type = TokenTypeEnum.TOTP
        token7.algorithm = TokenAlgorithmEnum.SHA512

        url = otpService.tokenToOtpAuthUrl(token: token7)!
        let qr7 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr7!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/Google:alice@google.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512&digits=8&issuer=Google&period=60")
        }

        // Test case 8: TOTP token with empty secret
        let token8 = Token()
        token8.issuer = "Example"
        token8.account = "user@example.com"
        token8.period = 30
        token8.secret = ""
        token8.digits = 6
        token8.type = TokenTypeEnum.TOTP
        token8.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token8)!
        let qr8 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr8!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://totp/Example:user@example.com?secret=&algorithm=SHA1&digits=6&issuer=Example&period=30")
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
        let qr1 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr1!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=GitHub&counter=1")
        }

        // Test case 2: HOTP token without account
        let token2 = Token()
        token2.issuer = "GitHub"
        token2.counter = 1
        token2.secret = "JBSWY3DPEHPK3PXP"
        token2.digits = 6
        token2.type = TokenTypeEnum.HOTP
        token2.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token2)!
        let qr2 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr2!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=GitHub&counter=1")
        }

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
        let qr3 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr3!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/GitHub:user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=7&issuer=GitHub&counter=10")
        }

        // Test case 4: HOTP token without issuer
        let token4 = Token()
        token4.account = "user@github.com"
        token4.counter = 1
        token4.secret = "JBSWY3DPEHPK3PXP"
        token4.digits = 6
        token4.type = TokenTypeEnum.HOTP
        token4.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token4)!
        let qr4 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr4!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/user@github.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&counter=1")
        }

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
        let qr5 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr5!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/My%20Company:user+test@mycompany.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&issuer=My%20Company&counter=1")
        }

        // Test case 6: HOTP token with no issuer and no account
        let token6 = Token()
        token6.counter = 1
        token6.secret = "JBSWY3DPEHPK3PXP"
        token6.digits = 6
        token6.type = TokenTypeEnum.HOTP
        token6.algorithm = TokenAlgorithmEnum.SHA1

        url = otpService.tokenToOtpAuthUrl(token: token6)!
        let qr6 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr6!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/?secret=JBSWY3DPEHPK3PXP&algorithm=SHA1&digits=6&counter=1")
        }

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
        let qr7 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr7!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/Google:user@google.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512&digits=8&issuer=Google&counter=100")
        }

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
        let qr8 = EFQRCode.generate(for: url)
        detectQRCode(in: UIImage(cgImage: qr8!)) { detectedUrl in
            XCTAssertEqual(detectedUrl, "otpauth://hotp/Example:user@example.com?secret=&algorithm=SHA1&digits=6&issuer=Example&counter=1")
        }
    }
}

func detectQRCode(in image: UIImage, completion: @escaping (String?) -> Void) {
    guard let cgImage = image.cgImage else {
        completion(nil)
        return
    }

    let request = VNDetectBarcodesRequest { request, error in
        guard error == nil else {
            completion(nil)
            return
        }

        let results = request.results as? [VNBarcodeObservation]
        let payload = results?.first?.payloadStringValue
        completion(payload)
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
        } catch {
            completion(nil)
        }
    }
}
