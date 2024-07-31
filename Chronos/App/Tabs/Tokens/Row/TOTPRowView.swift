import Factory
import SwiftUI
import Combine

struct TOTPRowView: View {
    let token: Token

    @State private var otp = ""
    @State private var secsLeft = 0
    @State private var progress: Double = 1.0

    let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    let otpService = Container.shared.otpService()

    var body: some View {
        Text(!otp.isEmpty ? formatOtp(otp: otp) : otpService.generateTOTP(token: token))
            .font(.largeTitle)
            .fontWeight(.light)
            .lineLimit(1)
            .onReceive(timer) { _ in
                otp = otpService.generateTOTP(token: token)
            }
            .onAppear {
                otp = otpService.generateTOTP(token: token)
            }

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
                .animation(.easeInOut(duration: 0.2), value: progress)
                .onReceive(timer) { _ in
                    progress = Double(secsLeft) / Double(token.period)
                }
                .onAppear {
                    progress = Double(secsLeft) / Double(token.period)
                }

            Text(String(secsLeft))
                .font(.system(size: 12))
                .frame(width: 28, height: 28, alignment: .center)
                .onReceive(timer) { _ in
                    secsLeft = Int(timeLeftForToken(period: token.period))
                }
                .onAppear {
                    secsLeft = Int(timeLeftForToken(period: token.period))
                }
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

    func timeLeftForToken(period: Int) -> Double {
        let val = Double(period) - (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double(period)))

        return val.rounded(.up)
    }
}
