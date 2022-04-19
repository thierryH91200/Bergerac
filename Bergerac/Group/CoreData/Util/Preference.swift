import AppKit

final class Preference : NSObject {
    
    static let shared = Preference()
    var entityPreference = [EntityPreference]()
    
    var viewContext : NSManagedObjectContext?


    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    func getAllDatas() -> EntityPreference {
        
        guard currentAccount != nil else {
            return entityPreference[0] }
        
        let fetchRequest = NSFetchRequest<EntityPreference>(entityName: "EntityPreference")
        let predicate = NSPredicate(format: "account == %@", currentAccount!)
        fetchRequest.predicate = predicate
        
        do {
            entityPreference = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        if entityPreference.isEmpty == true {
            return create(account: currentAccount!)
        }
        return entityPreference.first!
    }
    
    // MARK: - Create
    func create ( account: EntityAccount) -> EntityPreference {
        
        let entityPreference = NSEntityDescription.insertNewObject(forEntityName: "EntityPreference", into: viewContext!) as? EntityPreference

        var rubric = Rubric.shared.getAllDatas()
        rubric = rubric.sorted { $0.name! < $1.name! }
        
        var categories = rubric.first?.category?.allObjects as! [EntityCategory]
        categories = categories.sorted { $0.name! < $1.name! }
        entityPreference!.category = categories.first

        let modesPaiement = PaymentMode.shared.getAllDatas()
        entityPreference!.paymentMode = modesPaiement.first
        
        entityPreference!.statut = 1
        entityPreference!.signe = true
        entityPreference!.account = currentAccount

        return entityPreference!
    }
}
