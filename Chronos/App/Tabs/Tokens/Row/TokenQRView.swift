import EFQRCode
import Factory
import SwiftUI

struct TokenQRView: View {
    @Environment(\.dismiss) var dismiss

    @State var token: Token

    let otpService = Container.shared.otpService()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack(spacing: 2) {
                    Text(!token.issuer.isEmpty ? token.issuer : token.account)
                        .fontWeight(.semibold)
                        .font(.title2)
                        .lineLimit(1)

                    if !token.issuer.isEmpty && !token.account.isEmpty {
                        Text("\(token.account)")
                            .foregroundStyle(.gray)
                            .font(.title3)
                            .lineLimit(1)
                    }
                }
                .padding(.bottom, 8)

                if let otpAuthUrl = otpService.generateOtpAuthUrl(token: token),
                   let image = EFQRCode.generate(for: otpAuthUrl.absoluteString)
                {
                    Image(uiImage: UIImage(cgImage: image))
                        .resizable()
                        .frame(width: 256, height: 256)
                } else {
                    ZStack {
                        Rectangle()
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 256, height: 256)
                        Text("Failed to generate QR code")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(width: 256, height: 256)
                }

                Spacer()
            }
            .navigationBarItems(trailing: Button("Close", action: {
                dismiss()
            }))
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
    }
}
