import CoreData
import Foundation


extension EntityRubric {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityRubric> {
        return NSFetchRequest<EntityRubric>(entityName: "EntityRubric")
    }

    @NSManaged public var color: NSObject?
    @NSManaged public var name: String?
//    @NSManaged public var total: Double
    @NSManaged public var uuid: UUID?
    @NSManaged public var category: NSSet?
    @NSManaged public var account: EntityAccount?

}

// MARK: Generated accessors for category
extension EntityRubric {

    @objc(addCategoryObject:)
    @NSManaged public func addToCategory(_ value: EntityCategory)

    @objc(removeCategoryObject:)
    @NSManaged public func removeFromCategory(_ value: EntityCategory)

    @objc(addCategory:)
    @NSManaged public func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged public func removeFromCategory(_ values: NSSet)

}

extension EntityRubric {
    
    @objc var  children: NSSet {
        return category!
    }
    
    @objc var count: Int {
        return category!.count
    }
    
    @objc var isLeaf: Int {
        return 0
    }
    
}

extension EntityRubric {
    @objc var total: Double {
        // Create and cache the section total on demand.
        
        self.willAccessValue(forKey: "total")
        var _total = self.primitiveValue(forKey: "total") as! Double
        self.didAccessValue(forKey: "total")
        
        _total = 0.0
        let sousTotaux = category?.allObjects as! [EntityCategory]
        for soustotal in sousTotaux {
            _total += soustotal.objectif
        }
        self.setPrimitiveValue(_total, forKey: "total")
        return _total
    }
}
