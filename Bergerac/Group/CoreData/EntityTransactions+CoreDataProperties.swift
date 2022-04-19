import CoreData
import Foundation


extension EntityTransactions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityTransactions> {
        return NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
    }

    @NSManaged public var dateCree: Date?
    @NSManaged public var dateModifie: Date?
    @NSManaged public var dateOperation: Date?
//    @NSManaged public var datePointage: Date?
    @NSManaged public var checkNumber: String?
    @NSManaged public var bankStatement: Double
//    @NSManaged public var sectionIdentifier: String?
//    @NSManaged public var sectionYear: String?
    @NSManaged public var solde: Double
    @NSManaged public var statut: Int16
    @NSManaged public var uuid: UUID?
//    @NSManaged public var amount: Double
    @NSManaged public var sousOperations: NSSet?
    @NSManaged public var account: EntityAccount?
    @NSManaged public var paymentMode: EntityPaymentMode?
    @NSManaged public var operationLiee: EntityTransactions?

}

// MARK: Generated accessors for sousOperations
extension EntityTransactions {

    @objc(addSousOperationsObject:)
    @NSManaged public func addToSousOperations(_ value: EntitySousOperations)

    @objc(removeSousOperationsObject:)
    @NSManaged public func removeFromSousOperations(_ value: EntitySousOperations)

    @objc(addSousOperations:)
    @NSManaged public func addToSousOperations(_ values: NSSet)

    @objc(removeSousOperations:)
    @NSManaged public func removeFromSousOperations(_ values: NSSet)

}

extension EntityTransactions {
    
    @objc var sectionIdentifier: String? {
        // Create and cache the section identifier on demand.
        
        self.willAccessValue(forKey: "sectionIdentifier")
        var tmp = self.primitiveValue(forKey: "sectionIdentifier") as? String
        self.didAccessValue(forKey: "sectionIdentifier")
        
        if tmp == nil {
            if let timeStamp = self.value(forKey: "datePointage") as? Date {
                /*
                 Sections are organized by month and year. Create the section
                 identifier as a string representing the number (year * 100) + month;
                 this way they will be correctly ordered chronologically regardless
                 of the actual name of the month.
                 */
                let calendar  = Calendar.current
                let requestedComponents: Set<Calendar.Component> = [ .year, .month ]
                let components = calendar.dateComponents( requestedComponents, from: timeStamp)
                
                tmp = String(format: "%ld", components.year! * 100 + components.month!)
                self.setPrimitiveValue(tmp, forKey: "sectionIdentifier")
            }
        }
        return tmp
    }
    
    @objc var sectionYear: String? {
        // Create and cache the section identifier on demand.
        
        self.willAccessValue(forKey: "sectionYear")
        var tmp = self.primitiveValue(forKey: "sectionYear") as? String
        self.didAccessValue(forKey: "sectionYear")
        
        if tmp == nil {
            if let timeStamp = self.value(forKey: "datePointage") as? Date {
                /*
                 Sections are organized by month and year. Create the section
                 identifier as a string representing the number (year * 100) + month;
                 this way they will be correctly ordered chronologically regardless
                 of the actual name of the month.
                 */
                let calendar  = Calendar.current
                let requestedComponents: Set<Calendar.Component> = [ .year, .month ]
                let components = calendar.dateComponents( requestedComponents, from: timeStamp)
                
                tmp = String(format: "%ld", components.year! )
                self.setPrimitiveValue(tmp, forKey: "sectionYear")
            }
        }
        return tmp
    }

    @objc var amount: Double {
        
        self.willAccessValue(forKey: "amount")
        var _total = self.primitiveValue(forKey: "amount") as! Double
        self.didAccessValue(forKey: "amount")
        
        _total = 0.0
        let sousTotaux = sousOperations?.allObjects as! [EntitySousOperations]
        for soustotal in sousTotaux {
            _total += soustotal.amount
        }
        self.setPrimitiveValue(_total, forKey: "amount")
        return _total
    }
    
    @objc var datePointage: Date? {
        get {
            self.willAccessValue(forKey: "datePointage")
            let tmp = self.primitiveValue(forKey: "datePointage") as? Date
            self.didAccessValue(forKey: "datePointage")
            return tmp
        }
        set {
            self.willChangeValue(forKey: "datePointage")
            self.setPrimitiveValue(newValue, forKey: "datePointage")
            self.didChangeValue(forKey: "datePointage")
            // If the time stamp changes, the section identifier become invalid.
            self.setPrimitiveValue(nil, forKey: "sectionIdentifier")
            self.setPrimitiveValue(nil, forKey: "sectionYear")
        }
    }
//    @objc var dateOperation: Date? {
//        get {
//            self.willAccessValue(forKey: "dateOperation")
//            let tmp = self.primitiveValue(forKey: "dateOperation") as? Date
//            self.didAccessValue(forKey: "dateOperation")
//            return tmp
//        }
//        set {
//            self.willChangeValue(forKey: "dateOperation")
//            self.setPrimitiveValue(newValue, forKey: "dateOperation")
//            self.didChangeValue(forKey: "dateOperation")
//            // If the time stamp changes, the section identifier become invalid.
//            self.setPrimitiveValue(nil, forKey: "sectionIdentifier")
//        }
//    }

}


