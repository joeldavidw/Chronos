import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let fileUrl: URL

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
