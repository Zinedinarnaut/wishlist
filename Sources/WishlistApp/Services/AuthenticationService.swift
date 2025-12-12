import Foundation
import AuthenticationServices
import CloudKit

protocol AuthenticationServicing {
    var currentUser: UserProfile? { get }
    func restore() async -> UserProfile?
    func signIn() async throws -> UserProfile
    func signOut()
}

final class AuthenticationService: NSObject, AuthenticationServicing {
    private let keychain = KeychainStore(service: "WishlistApp")
    private let userIdentifierKey = "appleUserIdentifier"
    private(set) var currentUser: UserProfile?

    func restore() async -> UserProfile? {
        guard let identifier = try? keychain.read(key: userIdentifierKey) else { return nil }
        let profile = UserProfile(id: identifier)
        currentUser = profile
        return profile
    }

    func signIn() async throws -> UserProfile {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = SignInDelegate()
        controller.delegate = delegate

        return try await withCheckedThrowingContinuation { continuation in
            delegate.onComplete = { result in
                switch result {
                case .success(let profile):
                    self.currentUser = profile
                    continuation.resume(returning: profile)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            controller.performRequests()
        }
    }

    func signOut() {
        currentUser = nil
        try? keychain.delete(key: userIdentifierKey)
    }
}

private final class SignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    var onComplete: ((Result<UserProfile, Error>) -> Void)?

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let identifier = credential.user
            let profile = UserProfile(id: identifier)
            do {
                let keychain = KeychainStore(service: "WishlistApp")
                try keychain.save(key: "appleUserIdentifier", value: identifier)
                onComplete?(.success(profile))
            } catch {
                onComplete?(.failure(error))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onComplete?(.failure(error))
    }
}
