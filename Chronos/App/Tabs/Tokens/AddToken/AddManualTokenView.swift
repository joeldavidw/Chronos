import Factory
import SwiftUI

struct AddManualTokenView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State var showSecret: Bool = false

    @State private var issuer: String = ""
    @State private var account: String = ""
    @State private var secret: String = ""
    @State private var type: TokenTypeEnum = .TOTP
    @State private var algorithm: TokenAlgorithmEnum = .SHA1
    @State private var digits: Int = 6
    @State private var counter: Int = 0
    @State private var period: Int = 30

    let cryptoService = Container.shared.cryptoService()

    let parentDismiss: DismissAction

    init(_parentDismiss: DismissAction) {
        _issuer = State(initialValue: "")
        _account = State(initialValue: "")
        _secret = State(initialValue: "")
        _type = State(initialValue: TokenTypeEnum.TOTP)
        _algorithm = State(initialValue: TokenAlgorithmEnum.SHA1)
        _digits = State(initialValue: 6)
        _counter = State(initialValue: 0)
        _period = State(initialValue: 30)
        parentDismiss = _parentDismiss
    }

    var body: some View {
        Form {
            Section(header: Text("Information")) {
                LabeledContent {
                    TextField("Issuer", text: $issuer)
                } label: {
                    Text("Issuer")
                }
                LabeledContent("Account") {
                    TextField("Account", text: $account)
                }
                LabeledContent("Secret") {
                    Group {
                        if showSecret {
                            TextField("Secret", text: $secret)
                        } else {
                            SecureField("Secret", text: $secret)
                        }
                    }
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    Spacer()
                    Button {
                        showSecret.toggle()
                    } label: {
                        if showSecret {
                            Image(systemName: "eye.slash")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        } else {
                            Image(systemName: "eye")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Section(header: Text("Token Type")) {
                Picker("Type", selection: $type) {
                    ForEach(TokenTypeEnum.allCases) { _type in
                        Text(_type.rawValue).tag(_type)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
            }
            .listSectionSpacing(12)

            Section {
                if type == TokenTypeEnum.TOTP {
                    Picker("Algorithm", selection: $algorithm) {
                        ForEach(TokenAlgorithmEnum.allCases) { algo in
                            Text(algo.rawValue).tag(algo)
                        }
                    }

                    Picker("Digits", selection: $digits) {
                        ForEach([6, 7, 8], id: \.self) { digit in
                            Text(String(digit))
                        }
                    }

                    LabeledContent("Period") {
                        TextField("Period", value: $period, formatter: NumberFormatter())
                            .keyboardType(.asciiCapableNumberPad)
                    }
                }

                if type == TokenTypeEnum.HOTP {
                    LabeledContent("Counter") {
                        TextField("Counter", value: $counter, formatter: NumberFormatter())
                            .keyboardType(.asciiCapableNumberPad)
                    }
                }
            }
        }

        .multilineTextAlignment(.trailing)
        .navigationBarItems(leading: Button("Cancel", action: {
            dismiss()
        }))
        .navigationBarItems(trailing: Button("Save", action: {
            let newToken = Token()
            newToken.issuer = issuer
            newToken.account = account
            newToken.secret = secret
            newToken.type = type
            newToken.algorithm = algorithm
            newToken.digits = digits
            newToken.counter = counter
            newToken.period = period

            let newEncToken = cryptoService.encryptToken(token: newToken)
            modelContext.insert(newEncToken)
            try? modelContext.save()

            parentDismiss()
            dismiss()
        }).disabled(!isValid))
    }
}

extension AddManualTokenView {
    var isValid: Bool {
        let tempToken = Token()
        tempToken.issuer = issuer
        tempToken.account = account
        tempToken.secret = secret
        tempToken.type = type
        tempToken.algorithm = algorithm
        tempToken.digits = digits
        tempToken.counter = counter
        tempToken.period = period

        let valid = validateToken(token: tempToken)

        return valid.isValid
    }
}
