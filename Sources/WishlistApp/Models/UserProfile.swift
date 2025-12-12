import Foundation
import CloudKit

struct UserProfile: Identifiable, Hashable {
    let id: String
    let createdAt: Date

    init(id: String, createdAt: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
    }
}
