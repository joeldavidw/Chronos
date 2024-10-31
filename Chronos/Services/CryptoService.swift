import CryptoSwift
import Factory
import Foundation
import Logging
import SwiftData

enum CryptoError: Error {
    case decryptionFailed
    case randomBytesGenerationFailed
}

public class CryptoService {
    private let logger = Logger(label: "CryptoService")

    private let stateService = Container.shared.stateService()
    private let vaultService = Container.shared.vaultService()

    // scrypt paramaters - n: 2^17, r: 8, p: 1
    private let kdfParams = KdfParams(type: 0, n: 1 << 17, r: 8, p: 1)

    @MainActor
    func wrapMasterKeyWithUserPassword(password: [UInt8]) async -> ChronosCrypto {
        let passwordSalt = try! generateRandomSaltHexString()
        let passwordParams = PasswordParams(salt: passwordSalt)

        let passwordHash = Array(createPasswordHash(password: password, salt: passwordSalt, kdfParms: kdfParams)!)

        let iv = Array(try! generateRandom192BitNonce())
        let header = Array("".utf8)

        do {
            let encrypt = try AEADXChaCha20Poly1305.encrypt(Array(stateService.masterKey), key: passwordHash, iv: iv, authenticationHeader: header)

            let keyParams = KeyParams(iv: iv, tag: encrypt.authenticationTag)

            let newPasswordCrypto = ChronosCrypto(key: encrypt.cipherText, keyParams: keyParams, passwordParams: passwordParams, kdfParams: kdfParams)

            return newPasswordCrypto
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    @MainActor
    func unwrapMasterKeyWithUserPassword(vault: Vault?, password: [UInt8], isRestore _: Bool = false) async -> Bool {
        guard let vault = vault else {
            return false
        }

        guard let cryptoArr = vault.chronosCryptos else {
            logger.error("No crypto found in vault")
            return false
        }

        if cryptoArr.isEmpty {
            logger.error("Empty crypto found in vault")
            return false
        }

        guard let crypto = cryptoArr.first else {
            logger.error("Empty crypto found in vault")
            return false
        }

        let passwordHash = Array(createPasswordHash(password: password, salt: crypto.passwordParams!.salt, kdfParms: kdfParams)!)

        let header = Array("".utf8)

        do {
            guard let cryptoKey = crypto.key, let keyParams = crypto.keyParams else {
                logger.error("cryptoKey or keyParams is nil")
                return false
            }

            var decrypt = try AEADXChaCha20Poly1305.decrypt(cryptoKey, key: passwordHash, iv: keyParams.iv, authenticationHeader: header, authenticationTag: keyParams.tag)

            if decrypt.success {
                stateService.masterKey = SecureBytes(bytes: decrypt.plainText)
                stateService.setVaultId(vaultId: vault.vaultId!)

                decrypt.plainText.removeAll()
                return true
            } else {
                logger.error("Unable to decrypt crypto with passwordHash")
                return false
            }
        } catch {
            logger.error("Error encountered while decrypting crypto. Error: \(error.localizedDescription)")
            return false
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
            print(error)
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
