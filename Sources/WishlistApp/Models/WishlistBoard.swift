import Foundation
import CloudKit

struct WishlistBoard: Identifiable, Hashable {
    let id: CKRecord.ID
    var name: String
    let userId: String
    let createdAt: Date

    init(id: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString),
         name: String,
         userId: String,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.userId = userId
        self.createdAt = createdAt
    }

    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let userId = record["userId"] as? String,
              let createdAt = record.creationDate else { return nil }
        self.id = record.recordID
        self.name = name
        self.userId = userId
        self.createdAt = createdAt
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "WishlistBoard", recordID: id)
        record["name"] = name as CKRecordValue
        record["userId"] = userId as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        return record
    }
}
