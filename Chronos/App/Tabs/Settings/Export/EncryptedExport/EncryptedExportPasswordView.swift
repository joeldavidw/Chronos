import Factory
import SwiftUI

struct EncryptedExportPasswordView: View {
    @State private var password: String = ""

    @State private var passwordInvalidMsg: String = ""
    @State private var isPasswordValid: Bool = false
    @State private var navigateToNextPage: Bool = false

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack {
            Image(systemName: "lock.square")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text("This password is used to securely encrypt your data. Choose a memorable, random, and unique password with at least 10 characters.")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            Text("Password")
                .padding(.top, 32)

            Group {
                SecureField("", text: $password)
                    .multilineTextAlignment(.center)
                    .background(Color.clear)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onChange(of: password) { _, _ in
                        validatePasswords()
                    }
                    .onAppear {
                        focusedField = .password
                    }
                    .onSubmit {
                        doSubmit()
                    }
            }
            .frame(height: 48)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            Spacer()
        }
        .padding([.horizontal], 24)
        .navigationTitle("Encrypted Export")
        .background(.chronosPurple)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .navigationBarItems(trailing: Button("Next", action: {
            doSubmit()
        }).disabled(!isPasswordValid))
        .navigationDestination(isPresented: $navigateToNextPage) {
            EncryptedExportConfirmPasswordView(password: password)
        }
    }

    func doSubmit() {
        if !isPasswordValid {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        navigateToNextPage = true
    }

    private func validatePasswords() {
        if password.count < 10 {
            isPasswordValid = false
            passwordInvalidMsg = "Passwords must be at least 10 characters long"
        } else {
            isPasswordValid = true
            passwordInvalidMsg = ""
        }
    }
}
