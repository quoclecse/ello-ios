////
///  Relationship.swift
//

import SwiftyJSON


let RelationshipVersion = 1

@objc(Relationship)
final class Relationship: JSONAble {

    // active record
    let id: String
    let createdAt: Date
    // required
    let ownerId: String
    let subjectId: String
    // computed
    var owner: User? {
        return ElloLinkedStore.shared.getObject(self.ownerId, type: .usersType) as? User
    }
    var subject: User? {
        return ElloLinkedStore.shared.getObject(self.subjectId, type: .usersType) as? User
    }

    init(id: String, createdAt: Date, ownerId: String, subjectId: String) {
        self.id = id
        self.createdAt = createdAt
        self.ownerId = ownerId
        self.subjectId = subjectId
        super.init(version: RelationshipVersion)
    }

// MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.ownerId = decoder.decodeKey("ownerId")
        self.subjectId = decoder.decodeKey("subjectId")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(ownerId, forKey: "ownerId")
        coder.encodeObject(subjectId, forKey: "subjectId")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        var createdAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = Globals.now
        }

        let relationship = Relationship(
            id: json["id"].stringValue,
            createdAt: createdAt,
            ownerId: json["links"]["owner"]["id"].stringValue,
            subjectId: json["links"]["subject"]["id"].stringValue
        )
        return relationship
    }
}

extension Relationship: JSONSaveable {
    var uniqueId: String? { return "Relationship-\(id)" }
    var tableId: String? { return id }

}
