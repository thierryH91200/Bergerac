import AppKit

final class BankStatement : NSObject {
    
    static let shared = BankStatement()
    private var entities = [EntityBankStatement]()
    
    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
        // delete Transaction
    func remove(entity: EntityBankStatement)
    {
        viewContext!.undoManager?.beginUndoGrouping()
        viewContext!.undoManager?.setActionName("DeleteBankStatement")
        viewContext!.delete(entity)
        viewContext!.undoManager?.endUndoGrouping()
    }

    func getAllDatas() -> [EntityBankStatement] {
        
        do {
            let fetchRequest = NSFetchRequest<EntityBankStatement>(entityName: "EntityBankStatement")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
            
            entities = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
}
