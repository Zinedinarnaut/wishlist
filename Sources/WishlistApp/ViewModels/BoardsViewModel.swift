import Foundation

@MainActor
final class BoardsViewModel: ObservableObject {
    @Published var boards: [WishlistBoard] = []
    @Published var isLoading = false
    @Published var error: String?

    private let cloud: CloudKitServicing
    private var userId: String

    init(userId: String, cloud: CloudKitServicing = CloudKitService()) {
        self.userId = userId
        self.cloud = cloud
    }

    func updateUser(id: String) {
        userId = id
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            boards = try await cloud.fetchBoards(for: userId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createBoard(name: String) async {
        do {
            let board = try await cloud.createBoard(name: name, userId: userId)
            boards.append(board)
            Haptics.impact(style: .light)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func renameBoard(_ board: WishlistBoard, name: String) async {
        do {
            if let index = boards.firstIndex(of: board) {
                let updated = try await cloud.renameBoard(board, name: name)
                boards[index] = updated
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteBoard(_ board: WishlistBoard) async {
        do {
            try await cloud.deleteBoard(board)
            boards.removeAll { $0.id == board.id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
