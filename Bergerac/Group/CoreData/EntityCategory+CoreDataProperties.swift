import CoreData
import Foundation


extension EntityCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityCategory> {
        return NSFetchRequest<EntityCategory>(entityName: "EntityCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var objectif: Double
    @NSManaged public var uuid: UUID?
    @NSManaged public var echeancier: NSSet?
    @NSManaged public var preference: EntityPreference?
    @NSManaged public var rubric: EntityRubric?
    @NSManaged public var sousOperations: NSSet?

}

// MARK: Generated accessors for echeancier
extension EntityCategory {

    @objc(addEcheancierObject:)
    @NSManaged public func addToEcheancier(_ value: EntitySchedule)

    @objc(removeEcheancierObject:)
    @NSManaged public func removeFromEcheancier(_ value: EntitySchedule)

    @objc(addEcheancier:)
    @NSManaged public func addToEcheancier(_ values: NSSet)

    @objc(removeEcheancier:)
    @NSManaged public func removeFromEcheancier(_ values: NSSet)

}

// MARK: Generated accessors for sousOperations
extension EntityCategory {

    @objc(addSousOperationsObject:)
    @NSManaged public func addToSousOperations(_ value: EntitySousOperations)

    @objc(removeSousOperationsObject:)
    @NSManaged public func removeFromSousOperations(_ value: EntitySousOperations)

    @objc(addSousOperations:)
    @NSManaged public func addToSousOperations(_ values: NSSet)

    @objc(removeSousOperations:)
    @NSManaged public func removeFromSousOperations(_ values: NSSet)

}

extension EntityCategory {
    
    @objc var  children: NSSet {
        return []
    }
    
    @objc var count: Int {
        return 0
    }
    
    @objc var isLeaf: Int {
        return 1
    }
    
}

