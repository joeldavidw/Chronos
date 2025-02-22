import Factory
import SwiftUI

struct UpdateTokenView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    @State var token: Token
    var encryptedToken: EncryptedToken

    private let cryptoService = Container.shared.cryptoService()
    private let stateService = Container.shared.stateService()

    @State private var issuer: String
    @State private var account: String
    @State private var secret: String
    @State private var type: TokenTypeEnum
    @State private var algorithm: TokenAlgorithmEnum
    @State private var digits: Int
    @State private var counter: Int
    @State private var period: Int
    @State private var tags: [String]

    @State var showSecret: Bool = false

    init(token: Token, encryptedToken: EncryptedToken) {
        self.token = token
        self.encryptedToken = encryptedToken

        _issuer = State(initialValue: token.issuer)
        _account = State(initialValue: token.account)
        _secret = State(initialValue: token.secret)
        _type = State(initialValue: token.type)
        _algorithm = State(initialValue: token.algorithm)
        _digits = State(initialValue: token.digits)
        _counter = State(initialValue: token.counter)
        _period = State(initialValue: token.period)
        _tags = State(initialValue: token.tags ?? [])
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
                                .disabled(true)
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
                }
            }

            if type == TokenTypeEnum.TOTP {
                Section(header: Text("TOTP")) {
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
            }

            if type == TokenTypeEnum.HOTP {
                Section(header: Text("HOTP")) {
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
            token.issuer = issuer
            token.account = account
            token.secret = secret
            token.type = type
            token.algorithm = algorithm
            token.digits = digits
            token.counter = counter
            token.period = period
            token.tags = tags

            cryptoService.updateEncryptedToken(encryptedToken: encryptedToken, token: token)
            dismiss()
        })
        .disabled(!isValid || !hasChanged))
    }
}

extension UpdateTokenView {
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

    var hasChanged: Bool {
        return issuer != token.issuer ||
            account != token.account ||
            secret != token.secret ||
            type != token.type ||
            algorithm != token.algorithm ||
            digits != token.digits ||
            counter != token.counter ||
            period != token.period ||
            tags != token.tags
    }
}
