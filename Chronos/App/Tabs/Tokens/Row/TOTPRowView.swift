import Combine
import Factory
import SwiftUI

struct TOTPRowView: View {
    let token: Token

    @State private var otp = ""
    @State private var secsLeft = 0
    @State private var progress: Double = 1.0

    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let otpService = Container.shared.otpService()

    var body: some View {
        Group {
            Text(!otp.isEmpty ? formatOtp(otp: otp) : otpService.generateTOTP(token: token))
                .font(.largeTitle)
                .fontWeight(.light)
                .lineLimit(1)
                .onAppear(perform: updateOtp)

            Spacer()

            ZStack(alignment: .leading) {
                Circle()
                    .stroke(
                        Color.gray.opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(width: 28, height: 28)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(
                        Color.white.opacity(0.8),
                        lineWidth: 2
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 28, height: 28)

                Text(String(secsLeft))
                    .font(.system(size: 12))
                    .frame(width: 28, height: 28, alignment: .center)
            }
            .onAppear(perform: updateProgress)
            .onReceive(timer) { _ in
                updateProgress()
            }
        }
    }

    private func updateOtp() {
        otp = otpService.generateTOTP(token: token)
    }

    private func updateProgress() {
        let timeLeft = timeLeftForToken(period: token.period)
        secsLeft = Int(timeLeft.rounded(.up))
        
        // Circle progress will look smooth; however, the high redraw count causes significant CPU load.
        // progress = timeLeft / Double(token.period)
        progress = Double(secsLeft) / Double(token.period)
                
        if secsLeft == token.period {
            updateOtp()
        }
    }

    private func formatOtp(otp: String) -> String {
        if otp.count < 6 {
            return otp
        }

        let index = (otp.count == 7 || otp.count == 8) ? 4 : 3
        var formattedOtp = otp
        let insertIndex = otp.index(otp.startIndex, offsetBy: index)

        formattedOtp.insert(" ", at: insertIndex)
        return formattedOtp
    }

    private func timeLeftForToken(period: Int) -> Double {
        return Double(period) - (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double(period)))
    }
}
