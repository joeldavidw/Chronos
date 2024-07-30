import SwiftUI

struct PrivacyView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .frame(width: 128, height: 128)
                Spacer()
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .background(.chronosPurple)
    }
}

#Preview {
    PrivacyView()
}
