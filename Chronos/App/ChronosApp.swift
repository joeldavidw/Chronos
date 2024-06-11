import SwiftUI

class LoginStatus: ObservableObject {
    @Published var loggedIn: Bool = false
}

@main
struct ChronosApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LoginStatus())
                .background(Color(red: 0.04, green: 0, blue: 0.11))
        }
    }
}
