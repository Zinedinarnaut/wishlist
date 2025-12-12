import Foundation
import SwiftUI
import CloudKit

@MainActor
final class BoardDetailViewModel: ObservableObject {
    @Published var items: [WishlistItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var board: WishlistBoard

    private let cloud: CloudKitServicing

    init(board: WishlistBoard, cloud: CloudKitServicing = CloudKitService()) {
        self.board = board
        self.cloud = cloud
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await cloud.fetchItems(for: board)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func addItem(from metadata: ProductMetadata, url: URL) async {
        let reference = CKRecord.Reference(recordID: board.id, action: .deleteSelf)
        let item = WishlistItem(
            boardId: reference,
            title: metadata.title ?? url.absoluteString,
            brand: metadata.brand,
            price: metadata.price,
            currency: metadata.currency,
            imageURL: metadata.imageURL,
            productURL: url,
            metadata: metadata.raw,
            order: items.count
        )
        do {
            let saved = try await cloud.addItem(item)
            withAnimation { items.append(saved) }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateNotes(for item: WishlistItem, notes: String) async {
        guard let index = items.firstIndex(of: item) else { return }
        var updated = item
        updated.notes = notes
        do {
            let saved = try await cloud.updateItem(updated)
            items[index] = saved
        } catch {
            self.error = error.localizedDescription
        }
    }

    func delete(_ item: WishlistItem) async {
        do {
            try await cloud.deleteItem(item)
            withAnimation { items.removeAll { $0.id == item.id } }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func reorder(from source: IndexSet, to destination: Int) async {
        items.move(fromOffsets: source, toOffset: destination)
        do {
            try await cloud.reorderItems(items)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
