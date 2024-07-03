import Factory
import SwiftUI

struct EncryptedExportConfirmPasswordView: View {
    let exportService = Container.shared.exportService()
    @StateObject private var viewModel = ConfirmPasswordViewModel()

    @EnvironmentObject var exportNav: ExportNavigation

    @State var password: String
    @State private var verifyPassword: String = ""
    @State private var passwordInvalidMsg: String = ""
    @State private var isPasswordValid: Bool = false
    @State private var exportDisabled: Bool = false

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack {
            Spacer()

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
                    .onAppear {
                        focusedField = .verifyPassword
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
        }
        .padding([.horizontal], 24)
        .navigationTitle("Encrypted Export")
        .background(Color(red: 0.04, green: 0, blue: 0.11))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button {
                doSubmit()
            } label: {
                Text("Export")
            }
            .disabled(!isPasswordValid || exportDisabled)
            .sheet(isPresented: $viewModel.showEncryptedExportSheet) {
                if let fileUrl = viewModel.exportFileUrl {
                    ActivityView(fileUrl: fileUrl)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(Visibility.hidden)
                        .onDisappear {
                            exportNav.showSheet = false
                        }
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
        )
    }

    func doSubmit() {
        if !isPasswordValid {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            exportDisabled = false
            return
        }

        exportDisabled = true
        viewModel.exportToEncryptedZip(password: password)
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

class ConfirmPasswordViewModel: ObservableObject {
    @Published var exportFileUrl: URL?
    @Published var showEncryptedExportSheet: Bool = false

    let exportService = Container.shared.exportService()

    func exportToEncryptedZip(password: String) {
        guard let fileUrl = exportService.exportToEncryptedZip(password: password) else {
            exportFileUrl = nil
            showEncryptedExportSheet = false

            return
        }

        exportFileUrl = fileUrl
        showEncryptedExportSheet = true
    }
}
