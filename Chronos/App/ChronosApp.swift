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
//                .background(Color("Background"))
        }
    }
}
