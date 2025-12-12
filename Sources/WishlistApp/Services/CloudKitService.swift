import Foundation
import CloudKit

protocol CloudKitServicing {
    func fetchBoards(for userId: String) async throws -> [WishlistBoard]
    func createBoard(name: String, userId: String) async throws -> WishlistBoard
    func renameBoard(_ board: WishlistBoard, name: String) async throws -> WishlistBoard
    func deleteBoard(_ board: WishlistBoard) async throws

    func fetchItems(for board: WishlistBoard) async throws -> [WishlistItem]
    func addItem(_ item: WishlistItem) async throws -> WishlistItem
    func updateItem(_ item: WishlistItem) async throws -> WishlistItem
    func deleteItem(_ item: WishlistItem) async throws
    func reorderItems(_ items: [WishlistItem]) async throws
}

final class CloudKitService: CloudKitServicing {
    private let container: CKContainer
    private let database: CKDatabase

    init(container: CKContainer = CKContainer.default()) {
        self.container = container
        self.database = container.privateCloudDatabase
    }

    func fetchBoards(for userId: String) async throws -> [WishlistBoard] {
        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: "WishlistBoard", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        var boards: [WishlistBoard] = []
        for try await result in database.records(matching: query) {
            let (record, _) = result
            if let board = WishlistBoard(record: record) {
                boards.append(board)
            }
        }
        return boards
    }

    func createBoard(name: String, userId: String) async throws -> WishlistBoard {
        let board = WishlistBoard(name: name, userId: userId)
        let record = board.toRecord()
        let saved = try await database.save(record)
        guard let savedBoard = WishlistBoard(record: saved) else { throw CKError(.internalError) }
        return savedBoard
    }

    func renameBoard(_ board: WishlistBoard, name: String) async throws -> WishlistBoard {
        var updatedBoard = board
        updatedBoard.name = name
        let saved = try await database.modifyRecords(saving: [updatedBoard.toRecord()], deleting: [])
        guard let first = saved.saveResults.first?.value,
              case let .success(record) = first,
              let savedBoard = WishlistBoard(record: record) else { throw CKError(.unknownItem) }
        return savedBoard
    }

    func deleteBoard(_ board: WishlistBoard) async throws {
        _ = try await database.modifyRecords(saving: [], deleting: [board.id])
    }

    func fetchItems(for board: WishlistBoard) async throws -> [WishlistItem] {
        let reference = CKRecord.Reference(recordID: board.id, action: .none)
        let predicate = NSPredicate(format: "boardId == %@", reference)
        let query = CKQuery(recordType: "WishlistItem", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        var items: [WishlistItem] = []
        for try await result in database.records(matching: query) {
            let (record, _) = result
            if let item = WishlistItem(record: record) {
                items.append(item)
            }
        }
        return items
    }

    func addItem(_ item: WishlistItem) async throws -> WishlistItem {
        let saved = try await database.save(item.toRecord())
        guard let savedItem = WishlistItem(record: saved) else { throw CKError(.internalError) }
        return savedItem
    }

    func updateItem(_ item: WishlistItem) async throws -> WishlistItem {
        let saved = try await database.save(item.toRecord())
        guard let savedItem = WishlistItem(record: saved) else { throw CKError(.internalError) }
        return savedItem
    }

    func deleteItem(_ item: WishlistItem) async throws {
        _ = try await database.modifyRecords(saving: [], deleting: [item.id])
    }

    func reorderItems(_ items: [WishlistItem]) async throws {
        let records = items.enumerated().map { offset, item -> CKRecord in
            var mutable = item
            mutable.order = offset
            return mutable.toRecord()
        }
        _ = try await database.modifyRecords(saving: records, deleting: [])
    }
}
