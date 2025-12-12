import SwiftUI

@main
struct WishlistApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        Group {
            if session.isAuthenticated {
                BoardsView()
            } else {
                LoginView()
            }
        }
        .task {
            await session.restoreSession()
        }
    }
}
