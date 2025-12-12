import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Wishlist")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.accent)
                Text("Private, synced wishlist across your Apple devices.")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                SignInWithAppleButton(.signIn, onRequest: { request in
                    request.requestedScopes = []
                }, onCompletion: { result in
                    Task { await handle(result: result) }
                })
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 32)
            }
            .padding()
        }
    }

    private func handle(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success:
            await session.signIn()
        case .failure:
            break
        }
    }
}
