import Foundation
import CloudKit

struct WishlistItem: Identifiable, Hashable {
    let id: CKRecord.ID
    let boardId: CKRecord.Reference
    var title: String
    var brand: String?
    var price: Decimal?
    var currency: String?
    var imageURL: URL?
    var productURL: URL
    var metadata: [String: String]
    var notes: String
    let createdAt: Date
    var order: Int

    init(id: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString),
         boardId: CKRecord.Reference,
         title: String,
         brand: String? = nil,
         price: Decimal? = nil,
         currency: String? = nil,
         imageURL: URL? = nil,
         productURL: URL,
         metadata: [String: String] = [:],
         notes: String = "",
         createdAt: Date = Date(),
         order: Int = 0) {
        self.id = id
        self.boardId = boardId
        self.title = title
        self.brand = brand
        self.price = price
        self.currency = currency
        self.imageURL = imageURL
        self.productURL = productURL
        self.metadata = metadata
        self.notes = notes
        self.createdAt = createdAt
        self.order = order
    }

    init?(record: CKRecord) {
        guard let boardReference = record["boardId"] as? CKRecord.Reference,
              let title = record["title"] as? String,
              let productURLString = record["productURL"] as? String,
              let productURL = URL(string: productURLString),
              let createdAt = record.creationDate else { return nil }

        self.id = record.recordID
        self.boardId = boardReference
        self.title = title
        self.brand = record["brand"] as? String
        if let priceNumber = record["price"] as? NSNumber {
            self.price = priceNumber.decimalValue
        } else {
            self.price = nil
        }
        self.currency = record["currency"] as? String
        if let imageURLString = record["imageURL"] as? String {
            self.imageURL = URL(string: imageURLString)
        }
        self.productURL = productURL
        self.metadata = record["metadata"] as? [String: String] ?? [:]
        self.notes = record["notes"] as? String ?? ""
        self.createdAt = createdAt
        self.order = record["order"] as? Int ?? 0
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "WishlistItem", recordID: id)
        record["boardId"] = boardId
        record["title"] = title as CKRecordValue
        if let brand { record["brand"] = brand as CKRecordValue }
        if let price { record["price"] = price as NSDecimalNumber }
        if let currency { record["currency"] = currency as CKRecordValue }
        if let imageURL { record["imageURL"] = imageURL.absoluteString as CKRecordValue }
        record["productURL"] = productURL.absoluteString as CKRecordValue
        record["metadata"] = metadata as CKRecordValue
        record["notes"] = notes as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["order"] = order as CKRecordValue
        return record
    }
}
