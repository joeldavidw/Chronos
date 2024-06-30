import Factory
import SwiftUI

struct EncryptedExportView: View {
    let exportService = Container.shared.exportService()

    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    @State private var showEncryptedExportSheet: Bool = false
    @State private var isEncrypting: Bool = false

    @State private var passwordInvalidMsg: String = ""
    @State private var isPasswordValid: Bool = false

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        NavigationStack {
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
                        .onSubmit {
                            focusedField = .verifyPassword
                        }
                        .onChange(of: password) { _, _ in
                            validatePasswords()
                        }
                }
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Text("Confirm password")
                    .padding(.top, 24)
                Group {
                    SecureField("", text: $verifyPassword)
                        .multilineTextAlignment(.center)
                        .background(Color.clear)
                        .focused($focusedField, equals: .verifyPassword)
                        .submitLabel(.done)
                        .onSubmit {
                            doSubmit()
                        }
                        .onChange(of: verifyPassword) { _, _ in
                            validatePasswords()
                        }
                }
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                if !isPasswordValid {
                    Text(passwordInvalidMsg)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .padding(.top, 4)
                }
                
                Spacer()

                Button {
                    doSubmit()
                } label: {
                    if !isEncrypting {
                        Text("Next")
                            .foregroundStyle(Color(red: 0.04, green: 0, blue: 0.11))
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 32)
                    } else {
                        ProgressView()
                            .tint(Color(red: 0.04, green: 0, blue: 0.11))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 32)
                    }
                }
                .disabled(!isPasswordValid)
                .padding(.top, 64)
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showEncryptedExportSheet) {
                    if let fileurl = exportService.exportToEncryptedZip(password: password) {
                        ActivityView(fileUrl: fileurl)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(Visibility.hidden)
                    } else {
                        VStack {
                            Image(systemName: "xmark.circle")
                                .fontWeight(.light)
                                .font(.system(size: 64))
                                .padding(.bottom, 8)
                            Text("An error occurred while during the export process")
                        }
                    }
                }
            }
            .navigationTitle("Encrypted Export")
            .padding([.horizontal], 24)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func doSubmit() {
        if !isPasswordValid {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        isEncrypting = true
        
        showEncryptedExportSheet = true
    }

    private func validatePasswords() {
        if password.count < 10 {
            isPasswordValid = false
            passwordInvalidMsg = "Passwords must be at least 10 characters long"
        } else if password != verifyPassword {
            isPasswordValid = false
            passwordInvalidMsg = "Passwords do not match"
        } else {
            isPasswordValid = true
            passwordInvalidMsg = ""
        }
    }
}
