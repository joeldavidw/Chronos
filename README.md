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

- **End-to-end encrypted**
  - Only encrypted token data, using `XChaCha20-Poly1305`, is stored on the device and in iCloud
- **Backup & Sync (optional)**
  - Effortlessly backup and sync your data with iCloud
- **Export**
  - Easily export your tokens for backup or transfer
  - Encrypted/unencrypted zip archive containing:
    - JSON
    - HTML with QR codes for scanning and printable for offline storage
- **Import**
  - 2FAS Authenticator
  - Aegis
  - Ente Authenticator
  - Raivo
  - Google Authenticator
  - LastPass Authenticator
- **Anonymous**
  - No telemetry
  - No app account required
- Built natively with Swift

## Screenshots (Preview)

[<img width=200 alt="Overview 1" src=".github/assets/previews/1.png?raw=true">](.github/assets/previews/1.png?raw=true)
[<img width=200 alt="Overview 2" src=".github/assets/previews/2.png?raw=true">](.github/assets/previews/2.png?raw=true)
[<img width=200 alt="Encrypted Backups" src=".github/assets/previews/4.png?raw=true">](.github/assets/previews/4.png?raw=true)
[<img width=200 alt="Adv. Edit" src=".github/assets/previews/5.png?raw=true">](.github/assets/previews/5.png?raw=true)

## License

This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
