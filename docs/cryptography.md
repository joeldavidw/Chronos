# Cryptography

## Primitives

### Key Derivation Function (KDF)

[scrypt](https://datatracker.ietf.org/doc/html/rfc7914) algorithm is used as the KDF to derive a key from a
user-provided password along with a randomly generated 256-bit array salt.

The parameters are as follows:

| Parameter | Value          |
|:----------|:---------------|
| N         | 2<sup>16</sup> |
| r         | 8              |
| p         | 1              |

Note: Although [OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) recommends
an `N` value of <code>2<sup>17</sup></code>, it cannot be confirmed at this time that such a value would not cause older
iOS devices to crash. This value might be increased in the future, and the hashing algorithm could be completely
switched to `Argon2` once it gains broader support.

### Authenticated Encryption with Associated Data (AEAD)

[XChaCha20-Poly1305](https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-xchacha#section-2) cipher is used to ensure
the confidentiality, integrity, and authenticity of data. The XChaCha20-Poly1305 variant was chosen specifically for its larger
192-bit nonce, which significantly reduces the risk of nonce collisions.

## Master Key

A 256-bit (32 bytes) array of cryptographically secure random bytes is generated on the device
using [SecRandomCopyBytes](https://developer.apple.com/documentation/security/1399291-secrandomcopybytes). It functions
as the the encryption key used to encrypt token data.

### Key Wrapping

An encryption key is derived from the user's password using [scrypt](#key-derivation-function-kdf). This derived key is
then used to wrap the master key with [XChaCha20-Poly1305](#authenticated-encryption-with-associated-data-aead) cipher,
effectively encrypting it. This process allows for the secure storage of the encrypted master key on the device and, if
enabled, in Apple iCloud.

### Biometrics

When biometric unlocking is enabled, the master key is stored in the device's Secure Enclave.
