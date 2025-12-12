import Foundation
import Combine

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var user: UserProfile?
    @Published var isAuthenticated = false
    private let authService: AuthenticationServicing

    init(authService: AuthenticationServicing = AuthenticationService()) {
        self.authService = authService
    }

    func restoreSession() async {
        if let user = await authService.restore() {
            self.user = user
            self.isAuthenticated = true
        }
    }

    func signIn() async {
        do {
            let profile = try await authService.signIn()
            user = profile
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    func signOut() {
        authService.signOut()
        user = nil
        isAuthenticated = false
    }
}
