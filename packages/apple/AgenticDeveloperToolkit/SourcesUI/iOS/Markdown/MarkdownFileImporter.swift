import UIKit
import UniformTypeIdentifiers

/// The document picker's delegate outlives the call that creates it, so the
/// importer holds one alive until it reports back and then lets it go.
@MainActor
public enum MarkdownFileImporter {

    private final class PickerDelegate: NSObject, UIDocumentPickerDelegate {
        private var retained: PickerDelegate?
        private let completion: (String?) -> Void

        init(completion: @escaping (String?) -> Void) {
            self.completion = completion
            super.init()
            self.retained = self
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            defer { retained = nil }
            let completion = self.completion
            guard let url = urls.first else { completion(nil); return }
            let scoped = url.startAccessingSecurityScopedResource()
            // Reading is dispatched off the main thread so a large document
            // does not freeze the UI while it loads; the security scope stays
            // open until that read finishes.
            DispatchQueue.global(qos: .userInitiated).async {
                let text = try? String(contentsOf: url, encoding: .utf8)
                if scoped { url.stopAccessingSecurityScopedResource() }
                DispatchQueue.main.async { completion(text) }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            defer { retained = nil }
            completion(nil)
        }
    }

    public static func present(
        from presenter: PlatformViewController,
        completion: @escaping (String?) -> Void
    ) {
        var types: [UTType] = [.plainText]
        if let markdown = UTType(filenameExtension: "md") { types.insert(markdown, at: 0) }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = PickerDelegate(completion: completion)
        presenter.present(picker, animated: true)
    }
}
