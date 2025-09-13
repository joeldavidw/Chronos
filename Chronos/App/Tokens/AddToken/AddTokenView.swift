import AlertKit
import CodeScanner
import Factory
import SwiftUI

struct AddTokenView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var cameraAccessDenied = false

    enum TokenSheetMode {
        case none // Scanning QR in camera view
        case manual // Manual form entry
        case scanned // Form from scanned QR
    }

    @State private var tokenSheetMode: TokenSheetMode = .none

    @State private var scannedToken: Token?

    @State var showSecret: Bool = false
    @State private var issuer: String = ""
    @State private var account: String = ""
    @State private var secret: String = ""
    @State private var tokenType: TokenTypeEnum = .TOTP
    @State private var algorithm: TokenAlgorithmEnum = .SHA1
    @State private var digits: Int = 6
    @State private var counter: Int = 0
    @State private var period: Int = 30
    @State private var tags: Set<String> = []

    @FocusState private var isSecretFieldFocused: Bool

    let cryptoService = Container.shared.cryptoService()
    let vaultService = Container.shared.vaultService()

    var body: some View {
        NavigationStack {
            switch tokenSheetMode {
            case .none:
                cameraView
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Scan Token")
            case .manual, .scanned:
                tokenForm
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("New Token")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if tokenSheetMode != .none {
                                Button("Back") {
                                    closeTokenForm()
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if tokenSheetMode != .none {
                                Button("Done") {
                                    saveToken()
                                }.disabled(!isValid)
                            }
                        }
                    }
            }
        }
    }
}

private extension AddTokenView {
    var cameraView: some View {
        VStack {
            if !cameraAccessDenied {
                CodeScannerView(
                    codeTypes: [.qr],
                    scanMode: .once,
                    scanInterval: 0.1,
                    shouldVibrateOnSuccess: false,
                    isPaused: tokenSheetMode != .none,
                    completion: handleScanResult
                )
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
            } else {
                VStack {
                    Spacer()
                    Text("Chronos requires camera access to scan 2FA QR codes.")
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .bold()
                        .padding(.horizontal, 16)

                    Button("Open Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    .padding(.top, 4)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(8)
            }

            Button {
                withAnimation {
                    tokenSheetMode = .manual
                }
            } label: {
                Text("Enter details manually")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)
            .padding(.vertical, 8)
        }
        .padding([.bottom, .leading, .trailing], 16)
    }

    var tokenForm: some View {
        Form {
            Section(header: Text("Information")) {
                LabeledContent("Issuer") {
                    TextField("Issuer (Optional)", text: $issuer)
                        .disableAutocorrection(true)
                }
                LabeledContent("Account") {
                    TextField("Account", text: $account)
                        .disableAutocorrection(true)
                        .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
                }
                LabeledContent("Tags") {
                    NavigationLink {
                        TokenTagsSelectionView(selectedTags: $tags)
                    } label: {
                        HStack {
                            Spacer()
                            Text(tags.joined(separator: ", "))
                        }
                    }
                }
                LabeledContent("Secret") {
                    secretField
                }
            }

            Section(header: Text("Token Type")) {
                Picker("Type", selection: $tokenType) {
                    ForEach(TokenTypeEnum.allCases) { typeOption in
                        Text(typeOption.rawValue).tag(typeOption)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
            }
            .listSectionSpacing(12)

            Section {
                if tokenType == .TOTP {
                    Picker("Algorithm", selection: $algorithm) {
                        ForEach(TokenAlgorithmEnum.allCases) { algo in
                            Text(algo.rawValue).tag(algo)
                        }
                    }

                    Picker("Digits", selection: $digits) {
                        ForEach([6, 7, 8], id: \.self) { number in
                            Text(String(number))
                        }
                    }

                    LabeledContent("Period") {
                        TextField("Period", value: $period, formatter: NumberFormatter())
                            .keyboardType(.asciiCapableNumberPad)
                    }
                } else if tokenType == .HOTP {
                    LabeledContent("Counter") {
                        TextField("Counter", value: $counter, formatter: NumberFormatter())
                            .keyboardType(.asciiCapableNumberPad)
                    }
                }
            }
        }
        .multilineTextAlignment(.trailing)
        .onAppear {
            initializeForm()
        }
    }

    var secretField: some View {
        HStack {
            Group {
                if showSecret {
                    TextField("Secret", text: $secret)
                        .focused($isSecretFieldFocused)
                } else {
                    SecureField("Secret", text: $secret)
                        .disabled(true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showSecret = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSecretFieldFocused = true
                            }
                        }
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .onChange(of: isSecretFieldFocused) { _, isFocused in
                if !isFocused {
                    showSecret = false
                }
            }
        }
    }
}

private extension AddTokenView {
    func handleScanResult(_ result: Result<ScanResult, ScanError>) {
        switch result {
        case let .success(scanResult):
            let scannedString = scanResult.string
            guard scannedString.starts(with: "otpauth://") else {
                AlertKitAPI.present(
                    title: "Invalid 2FA QR Code",
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
                return
            }

            do {
                let parsedToken = try OtpAuthUrlParser.parseOtpAuthUrl(otpAuthStr: scannedString)
                scannedToken = parsedToken
                withAnimation {
                    tokenSheetMode = .scanned
                }
            } catch {
                AlertKitAPI.present(
                    title: "Invalid 2FA QR Code",
                    subtitle: error.localizedDescription,
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
            }
        case .failure:
            DispatchQueue.main.async {
                cameraAccessDenied = true
            }
        }
    }

    func initializeForm() {
        if let scannedToken = scannedToken, tokenSheetMode == .scanned {
            issuer = scannedToken.issuer
            account = scannedToken.account
            secret = scannedToken.secret
            tokenType = scannedToken.type
            algorithm = scannedToken.algorithm
            digits = scannedToken.digits
            counter = scannedToken.counter
            period = scannedToken.period
            tags = scannedToken.tags ?? []
        }
    }

    func closeTokenForm() {
        issuer = ""
        account = ""
        secret = ""
        tokenType = .TOTP
        algorithm = .SHA1
        digits = 6
        counter = 0
        period = 30
        tags = []

        tokenSheetMode = .none
        scannedToken = nil
    }

    var isValid: Bool {
        let tempToken = Token()
        tempToken.issuer = issuer
        tempToken.account = account
        tempToken.secret = secret
        tempToken.type = tokenType
        tempToken.algorithm = algorithm
        tempToken.digits = digits
        tempToken.counter = counter
        tempToken.period = period
        tempToken.tags = tags

        return tempToken.isValid
    }

    func saveToken() {
        let newToken = Token()
        newToken.issuer = issuer
        newToken.account = account
        newToken.secret = secret
        newToken.type = tokenType
        newToken.algorithm = algorithm
        newToken.digits = digits
        newToken.counter = counter
        newToken.period = period
        newToken.tags = tags

        let encrypted = cryptoService.encryptToken(token: newToken)
        vaultService.insertEncryptedToken(encrypted)

        dismiss()
    }
}
