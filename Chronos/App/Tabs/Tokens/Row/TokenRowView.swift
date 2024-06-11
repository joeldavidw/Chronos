import AlertKit
import Factory
import SwiftUI

@Observable
class TokenRowViewModel {
    var encryptedToken: EncryptedToken
    var token: Token?
    let cryptoService = Container.shared.cryptoService()

    init(encyptedToken: EncryptedToken) {
        encryptedToken = encyptedToken
        decryptToken()
    }

    private func decryptToken() {
        token = cryptoService.decryptToken(encryptedToken: encryptedToken)
    }
}

struct TokenRowView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var showTokenUpdateSheet = false
    @State private var showTokenDeleteSheet = false

    @State private var selectedTokenForDeletion: Token?
    @State private var selectedTokenForUpdate: Token?

    let tokenRowViewModel: TokenRowViewModel
    let otpService = Container.shared.otpService()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let token = tokenRowViewModel.token {
                HStack(spacing: 4) {
                    Text(!token.issuer.isEmpty ? token.issuer : token.account)
                        .fontWeight(.semibold)

                    if !token.issuer.isEmpty && !token.account.isEmpty {
                        Text("- \(token.account)")
                            .foregroundStyle(.gray)
                    }
                }

                HStack {
                    switch token.type {
                    case TokenTypeEnum.TOTP:
                        TOTPRowView(token: token)
                    case TokenTypeEnum.HOTP:
                        HOTPRowView(token: token, encryptedToken: tokenRowViewModel.encryptedToken)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .padding(CGFloat(4))
        .listRowBackground(Color(red: 0.04, green: 0, blue: 0.11))
        .onTapGesture {
            if let token = tokenRowViewModel.token {
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
                UpdateTokenView(token: tokenToUpdate, encryptedToken: tokenRowViewModel.encryptedToken)
                    .interactiveDismissDisabled(true)
            }
        }
        .confirmationDialog("Delete?", isPresented: $showTokenDeleteSheet, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: {
                do {
                    modelContext.delete(tokenRowViewModel.encryptedToken)
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
                self.selectedTokenForDeletion = tokenRowViewModel.token
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
                self.selectedTokenForUpdate = tokenRowViewModel.token
                self.showTokenUpdateSheet.toggle()
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "square.and.pencil")
                    Text("Edit")
                }
            }
            .tint(.blue)
        }
    }
}
