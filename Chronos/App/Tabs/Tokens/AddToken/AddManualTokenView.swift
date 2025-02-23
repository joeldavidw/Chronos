import Factory
import SwiftUI

struct AddManualTokenView: View {
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
    @State private var tags: [String]

    let cryptoService = Container.shared.cryptoService()
    let vaultService = Container.shared.vaultService()

    var dismissAction: DismissAction

    init(dismissAction: DismissAction, token: Token? = nil) {
        _issuer = State(initialValue: token?.issuer ?? "")
        _account = State(initialValue: token?.account ?? "")
        _secret = State(initialValue: token?.secret ?? "")
        _type = State(initialValue: token?.type ?? TokenTypeEnum.TOTP)
        _algorithm = State(initialValue: token?.algorithm ?? TokenAlgorithmEnum.SHA1)
        _digits = State(initialValue: token?.digits ?? 6)
        _counter = State(initialValue: token?.counter ?? 0)
        _period = State(initialValue: token?.period ?? 30)
        _tags = State(initialValue: token?.tags ?? [])

        self.dismissAction = dismissAction
    }

    var body: some View {
        Form {
            Section(header: Text("Information")) {
                LabeledContent {
                    TextField("Issuer (Optional)", text: $issuer)
                        .disableAutocorrection(true)
                } label: {
                    Text("Issuer")
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
                    Group {
                        if showSecret {
                            TextField("Secret", text: $secret)
                                .disableAutocorrection(true)
                                .autocapitalization(/*@START_MENU_TOKEN@*/ .none/*@END_MENU_TOKEN@*/)
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
            newToken.tags = tags

            let newEncToken = cryptoService.encryptToken(token: newToken)
            vaultService.insertEncryptedToken(newEncToken)

            dismissAction()
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
        tempToken.tags = tags

        return tempToken.isValid
    }
}
