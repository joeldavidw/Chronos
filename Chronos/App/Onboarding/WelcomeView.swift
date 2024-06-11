import Factory
import SwiftData
import SwiftUI

struct WelcomeView: View {
    let swiftDataService = Container.shared.swiftDataService()

    @Query var chronosCryptos: [ChronosCrypto]

    @State private var getStartedPressed: Bool = false
    @State private var restorePressed: Bool = false

    @AppStorage(StateEnum.BIOMETRICS_AUTH_ENABLED.rawValue) var stateBiometricsAuth: Bool = false
    @AppStorage(StateEnum.ONBOARDING_COMPLETED.rawValue) var stateOnboardingCompleted: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    getStartedPressed.toggle()
                } label: {
                    Text("Get started")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.bordered)

                Button {
                    restorePressed.toggle()
                } label: {
                    Text("Restore")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 32)
                }
                .disabled(chronosCryptos.isEmpty)
                .buttonStyle(.borderless)
            }
            .padding([.horizontal], 24)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.04, green: 0, blue: 0.11))
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $getStartedPressed) {
                StorageSetupView()
            }
            .navigationDestination(isPresented: $restorePressed) {
                RestoreBackupView()
            }
        }
        .onAppear(perform: {
            swiftDataService.resetModelContainers()
        })
    }
}
