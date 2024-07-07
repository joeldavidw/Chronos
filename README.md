# Chronos

<p align="center">
  <img src=".github/assets/logo.png" width="128"/>
</p>

<p align="center">
Chronos is an open-source two-factor authentication (2FA) app for iOS, developed natively in SwiftUI. It aims to provide robust security and reliable backup features, supporting both time-based (TOTP) and counter-based (HOTP) authentication methods.
</p>

<p align="center">
  <a href="https://apps.apple.com/app/chronos-authenticator/id6503929490">
    <img src=".github/assets/Download_on_the_App_Store.svg"/>
  </a>
</p>

## Features

- End-to-end encrypted (E2EE)
    - Token data are encrypted using XChaCha20-Poly1305
- Secure decryption methods:
  - Password (derived with scrypt)
  - Face ID (via Secure Enclave)
- Automatic backup & sync to Apple iCloud (optional)
- Export
    - Plain text
    - Encrypted
    - HTML with QR codes for easy scanning (Coming soon)
- Built natively with Swift

## Screenshots (Preview)

[<img width=200 alt="Overview 1" src=".github/assets/previews/1.png?raw=true">](.github/assets/previews/1.png?raw=true)
[<img width=200 alt="Overview 2" src=".github/assets/previews/2.png?raw=true">](.github/assets/previews/2.png?raw=true)
[<img width=200 alt="Encrypted Backups" src=".github/assets/previews/4.png?raw=true">](.github/assets/previews/4.png?raw=true)
[<img width=200 alt="Adv. Edit" src=".github/assets/previews/5.png?raw=true">](.github/assets/previews/5.png?raw=true)

## License

This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
