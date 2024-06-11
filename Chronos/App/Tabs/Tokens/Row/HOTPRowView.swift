import Factory
import SwiftUI

struct HOTPRowView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var otp = ""
    @State private var disableIncrementBtn = false

    let cryptoService = Container.shared.cryptoService()
    let otpService = Container.shared.otpService()

    var token: Token
    var encryptedToken: EncryptedToken

    var body: some View {
        Text(formatOtp(otp: otp))
            .font(.largeTitle)
            .fontWeight(.light)
            .lineLimit(1)
            .onAppear {
                otp = otpService.generateHOTP(token: token)
            }
            .onChange(of: token.counter) { _, _ in
                otp = otpService.generateHOTP(token: token)
            }
        Spacer()
        Button {
            disableIncrementBtn = true

            token.counter += 1
            cryptoService.updateEncryptedToken(encryptedToken: encryptedToken, token: token)

            otp = otpService.generateHOTP(token: token)
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
