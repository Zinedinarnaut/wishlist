import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var userId: String
    private let session: SessionViewModel

    init(session: SessionViewModel) {
        self.session = session
        self.userId = session.user?.id ?? ""
    }

    func signOut() {
        session.signOut()
    }
}
