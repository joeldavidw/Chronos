import CryptoSwift
import Factory
import Foundation
import SwiftData

enum CryptoError: Error {
    case decryptionFailed
    case randomBytesGenerationFailed
}

public class CryptoService {
    let stateService = Container.shared.stateService()
    let swiftDataService = Container.shared.swiftDataService()

    let defaults = UserDefaults.standard

    // scrypt paramaters - n: 2^17, r: 8, p: 1
    let kdfParams = KdfParams(type: KdfEnum.SCRYPT, n: 1 << 17, r: 8, p: 1)

    func wrapMasterKeyWithUserPassword(password: [UInt8]) async {
        let passwordSalt = try! generateRandomSaltHexString()
        let passwordParams = PasswordParams(salt: passwordSalt)

        let passwordHash = Array(createPasswordHash(password: password, salt: passwordSalt, kdfParms: kdfParams)!)

        let iv = Array(try! generateRandom192BitNonce())
        let header = Array("".utf8)

        do {
            let encrypt = try AEADXChaCha20Poly1305.encrypt(Array(stateService.masterKey), key: passwordHash, iv: iv, authenticationHeader: header)

            let keyParams = KeyParams(iv: iv, tag: encrypt.authenticationTag)

            let newPasswordCrypto = ChronosCrypto(key: encrypt.cipherText, keyParams: keyParams, passwordParams: passwordParams, kdfParams: kdfParams)

            let context = ModelContext(swiftDataService.getModelContainer())
            context.insert(newPasswordCrypto)
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func unwrapMasterKeyWithUserPassword(password: [UInt8], isRestore: Bool = false) async -> Bool {
        let context = ModelContext(swiftDataService.getModelContainer(isRestore: isRestore))

        let cryptoArr = try! context.fetch(FetchDescriptor<ChronosCrypto>())

        if cryptoArr.isEmpty {
            stateService.resetAllStates()
        }

        let crypto: ChronosCrypto = cryptoArr.first!

        let passwordHash = Array(createPasswordHash(password: password, salt: crypto.passwordParams!.salt, kdfParms: kdfParams)!)

        let header = Array("".utf8)

        do {
            guard let cryptoKey = crypto.key, let keyParams = crypto.keyParams else {
                fatalError("var nil")
            }

            var decrypt = try AEADXChaCha20Poly1305.decrypt(cryptoKey, key: passwordHash, iv: keyParams.iv, authenticationHeader: header, authenticationTag: keyParams.tag)

            if decrypt.success {
                stateService.masterKey = SecureBytes(bytes: decrypt.plainText)
                decrypt.plainText.removeAll()
                return true
            } else {
                return false
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension CryptoService {
    func encryptToken(token: Token) -> EncryptedToken {
        do {
            let iv = try Array(generateRandom192BitNonce())
            let header = Array("".utf8)

            let tokenJson = try JSONEncoder().encode(token)
            let encrypt = try AEADXChaCha20Poly1305.encrypt(Array(tokenJson), key: Array(stateService.masterKey), iv: iv, authenticationHeader: header)

            return EncryptedToken(encryptedTokenCiper: encrypt.cipherText, iv: iv, authenticationTag: encrypt.authenticationTag, createdAt: Date())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func updateEncryptedToken(encryptedToken: EncryptedToken, token: Token) {
        do {
            let iv = try Array(generateRandom192BitNonce())
            let header = Array("".utf8)

            let tokenJson = try JSONEncoder().encode(token)
            let encrypt = try AEADXChaCha20Poly1305.encrypt(Array(tokenJson), key: Array(stateService.masterKey), iv: iv, authenticationHeader: header)

            encryptedToken.encryptedTokenCiper = encrypt.cipherText
            encryptedToken.authenticationTag = encrypt.authenticationTag
            encryptedToken.iv = iv
            try encryptedToken.modelContext?.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func decryptToken(encryptedToken: EncryptedToken) -> Token? {
        let header = Array("".utf8)

        guard let encryptedTokenCiper = encryptedToken.encryptedTokenCiper, let iv = encryptedToken.iv, let authenticationTag = encryptedToken.authenticationTag else {
            fatalError("var nil")
        }

        do {
            let decrypted = try AEADXChaCha20Poly1305.decrypt(encryptedTokenCiper, key: Array(stateService.masterKey), iv: iv, authenticationHeader: header, authenticationTag: authenticationTag)

            let tokenJson = try JSONDecoder().decode(Token.self, from: Data(decrypted.plainText))
            return tokenJson
        } catch {
            return nil
        }
    }
}

extension CryptoService {
    func createPasswordHash(password: [UInt8], salt: String, kdfParms: KdfParams) -> Data? {
        let password = Array(password)

        do {
            let hashedSecret = try Scrypt(password: password, salt: Array(hex: salt), dkLen: 32, N: kdfParms.n, r: kdfParms.r, p: kdfParms.p).calculate()
            return Data(hashedSecret)
        } catch {
            return nil
        }
    }

    // Generates a 256 bit master key
    func generateRandomMasterKey() throws -> SecureBytes {
        return try SecureBytes(bytes: Array(generateRandomBytes(count: 32)))
    }

    private func generateRandomBiometricsPassword() throws -> SecureBytes {
        return try SecureBytes(bytes: Array(generateRandomBytes(count: 32)))
    }

    private func generateRandomSaltHexString() throws -> String {
        let bytes = try generateRandomBytes(count: 32)
        return bytes.toHexString()
    }

    private func generateRandom192BitNonce() throws -> Data {
        return try generateRandomBytes(count: 24)
    }

    private func generateRandomBytes(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard result == errSecSuccess else {
            throw CryptoError.randomBytesGenerationFailed
        }

        return Data(bytes)
    }
}