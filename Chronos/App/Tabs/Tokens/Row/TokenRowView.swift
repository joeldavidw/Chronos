import AlertKit
import Combine
import Factory
import SwiftUI

struct TokenRowView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var showTokenDeleteSheet = false
    @State private var showTokenQRSheet = false

    @State private var selectedTokenForDeletion: Token?
    @State private var selectedTokenForUpdate: Token?

    @AppStorage(StateEnum.TAP_TO_REVEAL_ENABLED.rawValue) private var stateTapToRevealEnabled: Bool = false

    @State private var tokenRevealed = false

    let tokenPair: TokenPair

    let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    var token: Token {
        return tokenPair.token
    }

    var encryptedToken: EncryptedToken {
        return tokenPair.encToken
    }

    let otpService = Container.shared.otpService()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(!token.issuer.isEmpty ? token.issuer : token.account)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                if !token.issuer.isEmpty && !token.account.isEmpty {
                    Text("- \(token.account)")
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
            }

            if stateTapToRevealEnabled && !tokenRevealed {
                HStack {
                    Text(formatOtp(otp: Array(repeating: "•", count: token.digits).joined(separator: "")))
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .lineLimit(1)

                    Spacer()
                }
            } else {
                HStack {
                    switch token.type {
                    case TokenTypeEnum.TOTP:
                        TOTPRowView(token: token, timer: timer)
                    case TokenTypeEnum.HOTP:
                        HOTPRowView(token: token, encryptedToken: encryptedToken)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .padding(CGFloat(4))
        .listRowBackground(Color(red: 0.04, green: 0, blue: 0.11))
        .onTapGesture {
            if !stateTapToRevealEnabled {
                switch token.type {
                case TokenTypeEnum.TOTP:
                    UIPasteboard.general.string = otpService.generateTOTP(token: token)
                case TokenTypeEnum.HOTP:
                    UIPasteboard.general.string = otpService.generateHOTP(token: token)
                }

                AlertKitAPI.present(
                    title: "Copied",
                    icon: .done,
                    style: .iOS17AppleMusic,
                    haptic: .success
                )
            } else {
                tokenRevealed.toggle()
            }
        }
        .swipeActions(edge: .leading) {
            TokenRowLeftToRightSwipeView()
        }
        .swipeActions(edge: .trailing) {
            TokenRowRightToLeftSwipeView()
        }
        .sheet(item: $selectedTokenForUpdate) { tokenToUpdate in
            NavigationView {
                UpdateTokenView(token: tokenToUpdate, encryptedToken: encryptedToken)
                    .interactiveDismissDisabled(true)
            }
        }
        .sheet(isPresented: $showTokenQRSheet) {
            TokenQRView(token: token)
        }
        .confirmationDialog("Delete?", isPresented: $showTokenDeleteSheet, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: {
                do {
                    modelContext.delete(encryptedToken)
                    try modelContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            })

            Button("Cancel", role: .cancel, action: {
                self.showTokenDeleteSheet = false
                self.selectedTokenForDeletion = nil
            })
        } message: {
            if let tokenToDelete = self.selectedTokenForDeletion {
                Text("Permentaly delete **\(tokenToDelete.issuer)**?")
            }
        }
    }

    func TokenRowLeftToRightSwipeView() -> some View {
        return Group {
            Button {
                self.selectedTokenForDeletion = token
                self.showTokenDeleteSheet.toggle()
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
            .tint(.red)
        }
    }

    func TokenRowRightToLeftSwipeView() -> some View {
        return Group {
            Button {
                self.selectedTokenForUpdate = token
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "square.and.pencil")
                    Text("Edit")
                }
            }
            .tint(.blue)

            Button {
                self.showTokenQRSheet = true
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "qrcode")
                    Text("QR")
                }
            }
            .tint(.indigo)
        }
    }

    func formatOtp(otp: String) -> String {
        if otp.count < 6 {
            return otp
        }

        let index = (otp.count == 7 || otp.count == 8) ? 4 : 3
        var formattedOtp = otp
        let insertIndex = otp.index(otp.startIndex, offsetBy: index)

        formattedOtp.insert(" ", at: insertIndex)
        return formattedOtp
    }
}
