import Foundation

@MainActor
final class AddItemViewModel: ObservableObject {
    @Published var urlString: String = ""
    @Published var metadata: ProductMetadata?
    @Published var isLoading = false
    @Published var error: String?

    private let metadataService: MetadataServicing

    init(metadataService: MetadataServicing = MetadataService()) {
        self.metadataService = metadataService
    }

    func fetch() async {
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            metadata = try await metadataService.fetchMetadata(from: url)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
