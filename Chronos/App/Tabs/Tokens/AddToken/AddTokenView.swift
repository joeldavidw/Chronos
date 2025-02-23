import AlertKit
import CodeScanner
import Factory
import SwiftUI

struct AddTokenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var unableToAccessCamera = false
    @State private var showTokenManualAddSheet = false
    @State private var showTokenAddSheet = false

    @State private var newToken: Token?

    var body: some View {
        VStack {
            VStack {
                Text("Add Token")
                    .font(.title)
                    .bold()
                Text("Scan 2FA QR code or enter token details manually")
                    .font(.caption)
            }

            VStack {
                if !unableToAccessCamera {
                    CodeScannerView(
                        codeTypes: [.qr],
                        scanMode: .once,
                        scanInterval: 0.1,
                        shouldVibrateOnSuccess: false,
                        isPaused: showTokenManualAddSheet,
                        completion: handleScan
                    )
                    .frame(height: 200, alignment: .center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .cornerRadius(8)
                } else {
                    VStack {
                        Spacer()
                        Text("Chronos requires camera access to scan 2FA QR codes")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .bold()
                            .padding(.horizontal, 16)
                        Button("Open settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                        .padding(.top, 4)
                        Spacer()
                    }
                    .frame(height: 200, alignment: .center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(.black)
                    .cornerRadius(8)
                }

                Button {
                    showTokenManualAddSheet.toggle()
                } label: {
                    Text("Enter details manually")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 8)
                .sheet(isPresented: $showTokenManualAddSheet) {
                    NavigationView {
                        AddManualTokenView(_parentDismiss: dismiss)
                            .interactiveDismissDisabled(true)
                    }
                }
                .sheet(isPresented: Binding(
                    get: { showTokenAddSheet && newToken != nil },
                    set: { showTokenAddSheet = $0 }
                )) {
                    NavigationView {
                        AddManualTokenView(_parentDismiss: dismiss, token: newToken!)
                            .interactiveDismissDisabled(true)
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding(16)
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case let .success(result):
            dismiss()

            let otpAuthStr = result.string
            guard otpAuthStr.starts(with: "otpauth://") else {
                AlertKitAPI.present(
                    title: "Invalid 2FA QR Code",
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
                return
            }

            do {
                let newToken = try OtpAuthUrlParser.parseOtpAuthUrl(otpAuthStr: otpAuthStr)

                DispatchQueue.main.async {
                    self.newToken = newToken
                    showTokenAddSheet = true
                }
            } catch {
                AlertKitAPI.present(
                    title: "Invalid 2FA QR Code",
                    subtitle: error.localizedDescription.description,
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
            }
        case .failure:
            DispatchQueue.main.async {
                unableToAccessCamera = true
            }
        }
    }
}
