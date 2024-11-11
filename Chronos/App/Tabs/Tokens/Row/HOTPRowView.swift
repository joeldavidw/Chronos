import Factory
import SwiftUI

struct HOTPRowView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var otp = ""
    @State private var disableIncrementBtn = false

    let cryptoService = Container.shared.cryptoService()

    var token: Token
    var encryptedToken: EncryptedToken

    var body: some View {
        Text(!otp.isEmpty ? formatOtp(otp: otp) : token.generateOtp())
            .font(.largeTitle)
            .fontWeight(.light)
            .lineLimit(1)
            .onAppear {
                otp = token.generateOtp()
            }
            .onChange(of: token.counter) { _, _ in
                otp = token.generateOtp()
            }
            .animation(nil, value: UUID())
        Spacer()
        Button {
            disableIncrementBtn = true

            token.counter += 1
            cryptoService.updateEncryptedToken(encryptedToken: encryptedToken, token: token)

            otp = token.generateOtp()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                disableIncrementBtn = false
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 24))
                .fontWeight(.light)
                .rotationEffect(.degrees(disableIncrementBtn ? 360 : 0))
                .animation(.easeInOut(duration: 1), value: disableIncrementBtn)
        }
        .frame(width: 28, height: 28, alignment: .center)
        .disabled(disableIncrementBtn)
        .buttonStyle(.plain)
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
