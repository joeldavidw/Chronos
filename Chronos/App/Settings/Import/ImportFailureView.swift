import AlertKit
import Factory
import SwiftUI

struct ImportFailureView: View {
    @EnvironmentObject var importNav: ExportNavigation

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.square")
                .font(.system(size: 44))
                .padding(.bottom, 16)

            Text("The file cannot be imported. It might be corrupted as there was an error while trying to parse it.")
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                importNav.showSheet = false
            } label: {
                Text("Close")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("Import Failed")
        .padding([.horizontal], 24)
        .padding([.bottom], 32)
        .navigationBarTitleDisplayMode(.inline)
    }
}
