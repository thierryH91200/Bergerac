import AppKit

final class ListTransactions : NSObject {
    
    static let shared = ListTransactions()
    var entities = [EntityTransactions]()
    var ascending = false
    var viewContext : NSManagedObjectContext?
    
    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    // delete Transaction
    func remove(entity: EntityTransactions)
    {
        viewContext!.undoManager?.beginUndoGrouping()
        viewContext!.undoManager?.setActionName("DeleteTransaction")
        viewContext!.delete(entity)
        viewContext!.undoManager?.endUndoGrouping()
    }
    
    func find(uuid: UUID) -> EntityTransactions
    {
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        do {
            entities = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        if let i = entities.firstIndex(where: {$0.uuid == uuid}) {
            return entities[i]
        }
        
        return entities.first!
    }
    
    func getAllComment() -> [String] {
        
        var comments = [String]()
        
        let entityTransactions = getAllDatas()
        for entityTransaction in entityTransactions {
            let splitTransactions = entityTransaction.sousOperations?.allObjects as! [EntitySousOperations]
            
            for splitTransaction in splitTransactions {
                let comment = splitTransaction.libelle ?? ""
                comments.append(comment)
            }
        }
        return comments.uniqueElements
    }
    
    func getAllDatas(ascending: Bool = true) -> [EntityTransactions] {
        
        guard currentAccount != nil else { return [] }
        self.ascending = ascending
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        let predicate = NSPredicate(format: "account == %@", currentAccount!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "datePointage", ascending: ascending),
                                        NSSortDescriptor(key: "dateOperation", ascending: ascending)]

        do {
            entities = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
            return []
        }
        if currentAccount?.isDemo == true {
            adjustDate()
        }
        return entities
    }
    
    func adjustDate () {
        guard entities.isEmpty == false else {return}
        let diffDate = (entities.first?.dateOperation!.timeIntervalSinceNow)!
        for entity in entities {
            entity.datePointage  = (entity.datePointage!  - diffDate).noon
            entity.dateOperation = (entity.dateOperation! - diffDate).noon
        }
        currentAccount?.isDemo = false
    }
    
}

public extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}

// MARK: convert dictionary to class
class GroupedYearOperations : NSObject {
    let year     : String
    var allMonth : [GroupedMonthOperations]
    
    init( dictionary: (key: String, value: [String: [Transaction]])) {
        self.year = dictionary.key
        
        self.allMonth = [GroupedMonthOperations]()
        let months = (dictionary.value).map { (key: String , value: [Transaction]) -> GroupedMonthOperations in
            return GroupedMonthOperations(month : key , Transactions: value)
        }
        self.allMonth = months.sorted(by: {$0.month > $1.month})
    }
}

class GroupedMonthOperations : NSObject {
    let month       : String
    let transactions : [ Transaction ]
    
    init( month: String, Transactions: [Transaction]) {
        
        self.month = month
        let idAllOperation = (0 ..< Transactions.count).map { (i) -> Transaction in
            return Transaction(year : Transactions[i].year, id: Transactions[i].id, entityTransaction: Transactions[i].entityTransaction)
        }
        self.transactions = idAllOperation.sorted(by: { $0.entityTransaction.datePointage!.timeIntervalSince1970 > $1.entityTransaction.datePointage!.timeIntervalSince1970 })
    }
}

class Transaction : NSObject {
    let cb               : Bool
    let year             : String
    let id               : String
    let entityTransaction : EntityTransactions
    
    init( year: String, id: String, entityTransaction: EntityTransactions) {
        self.year = year
        self.id = id
        self.entityTransaction = entityTransaction
        let mode = self.entityTransaction.paymentMode?.name
        self.cb = mode == Localizations.PaymentMethod.Bank_Card ? true : false
    }
}

