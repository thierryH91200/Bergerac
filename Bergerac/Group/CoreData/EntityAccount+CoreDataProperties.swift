import CoreData
import Foundation


extension EntityAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityAccount> {
        return NSFetchRequest<EntityAccount>(entityName: "EntityAccount")
    }

    @NSManaged public var dateEcheancier: Date?
    @NSManaged public var name: String?
    @NSManaged public var nameImage: String?
    @NSManaged public var isFolder: Bool
    @NSManaged public var isDemo: Bool
    @NSManaged public var isAccount: Bool
    @NSManaged public var isHeader: Bool
    @NSManaged public var isRoot: Bool
    @NSManaged public var type: Int16
//    @NSManaged public var solde: Double
    @NSManaged public var uuid: UUID

    @NSManaged public var bank: EntityBank?
    @NSManaged public var carnetCheques: NSSet?
    @NSManaged public var echeanciers: NSSet?
    @NSManaged public var identity: EntityIdentity?
    @NSManaged public var initAccount: EntityInitAccount?
    @NSManaged public var modePaiement: NSSet?
    @NSManaged public var transactions: NSSet?
    @NSManaged public var preference: EntityPreference?
    @NSManaged public var rubrique: NSSet?
    @NSManaged public var children: NSOrderedSet?
    @NSManaged public var parent: EntityAccount?
}

// MARK: Generated accessors for carnetCheques
extension EntityAccount {

    @objc(addCarnetChequesObject:)
    @NSManaged public func addToCarnetCheques(_ value: EntityCarnetCheques)

    @objc(removeCarnetChequesObject:)
    @NSManaged public func removeFromCarnetCheques(_ value: EntityCarnetCheques)

    @objc(addCarnetCheques:)
    @NSManaged public func addToCarnetCheques(_ values: NSSet)

    @objc(removeCarnetCheques:)
    @NSManaged public func removeFromCarnetCheques(_ values: NSSet)

}

// MARK: Generated accessors for echeanciers
extension EntityAccount {

    @objc(addEcheanciersObject:)
    @NSManaged public func addToEcheanciers(_ value: EntitySchedule)

    @objc(removeEcheanciersObject:)
    @NSManaged public func removeFromEcheanciers(_ value: EntitySchedule)

    @objc(addEcheanciers:)
    @NSManaged public func addToEcheanciers(_ values: NSSet)

    @objc(removeEcheanciers:)
    @NSManaged public func removeFromEcheanciers(_ values: NSSet)

}

// MARK: Generated accessors for modePaiement
extension EntityAccount {

    @objc(addModePaiementObject:)
    @NSManaged public func addToModePaiement(_ value: EntityPaymentMode)

    @objc(removeModePaiementObject:)
    @NSManaged public func removeFromModePaiement(_ value: EntityPaymentMode)

    @objc(addModePaiement:)
    @NSManaged public func addToModePaiement(_ values: NSSet)

    @objc(removeModePaiement:)
    @NSManaged public func removeFromModePaiement(_ values: NSSet)

}

// MARK: Generated accessors for operations
extension EntityAccount {

    @objc(addOperationsObject:)
    @NSManaged public func addToTransactions(_ value: EntityTransactions)

    @objc(removeOperationsObject:)
    @NSManaged public func removeFromTransactions(_ value: EntityTransactions)

    @objc(addOperations:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeOperations:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

// MARK: Generated accessors for rubrique
extension EntityAccount {

    @objc(addRubricObject:)
    @NSManaged public func addToRubric(_ value: EntityRubric)

    @objc(removeRubricObject:)
    @NSManaged public func removeFromRubrique(_ value: EntityRubric)

    @objc(addRubric:)
    @NSManaged public func addToRubric(_ values: NSSet)

    @objc(removeRubrique:)
    @NSManaged public func removeFromRubric(_ values: NSSet)

}

// MARK: Generated accessors for children
extension EntityAccount {

    @objc(insertObject:inChildrenAtIndex:)
    @NSManaged public func insertIntoChildren(_ value: EntityAccount, at idx: Int)

    @objc(removeObjectFromChildrenAtIndex:)
    @NSManaged public func removeFromChildren(at idx: Int)

    @objc(insertChildren:atIndexes:)
    @NSManaged public func insertIntoChildren(_ values: [EntityAccount], at indexes: NSIndexSet)

    @objc(removeChildrenAtIndexes:)
    @NSManaged public func removeFromChildren(at indexes: NSIndexSet)

    @objc(replaceObjectInChildrenAtIndex:withObject:)
    @NSManaged public func replaceChildren(at idx: Int, with value: EntityAccount)

    @objc(replaceChildrenAtIndexes:withChildren:)
    @NSManaged public func replaceChildren(at indexes: NSIndexSet, with values: [EntityAccount])

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: EntityAccount)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: EntityAccount)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSOrderedSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSOrderedSet)

}

extension EntityAccount {
    @objc var solde: Double {
        // Create and cache the section total on demand.
        guard isAccount == true else { return 0.0 }
        
        self.willAccessValue(forKey: "solde")
        var _balance = self.primitiveValue(forKey: "solde") as! Double
        self.didAccessValue(forKey: "solde")
        
        _balance = 0.0
        let arrayTransactions = transactions?.allObjects as! [EntityTransactions]
        for transaction in arrayTransactions {
            _balance += transaction.amount
        }
        self.setPrimitiveValue(_balance, forKey: "total")
        return _balance
    }
}

