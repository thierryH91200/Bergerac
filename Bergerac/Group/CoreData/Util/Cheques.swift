import AppKit

final class ChequeBook : NSObject {
    
    static let shared = ChequeBook()
    private var entities = [EntityCarnetCheques]()
    
    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    func getAllDatas() -> [EntityCarnetCheques] {
        
        do {
            let fetchRequest = NSFetchRequest<EntityCarnetCheques>(entityName: "EntityCarnetCheques")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            
            entities = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        defaultCarnetCheques()
        return entities
    }
    
    func defaultCarnetCheques()
    {
        if entities.isEmpty == true {
            
            let entityCarnetCheques = NSEntityDescription.insertNewObject(forEntityName: "EntityCarnetCheques", into: viewContext!) as? EntityCarnetCheques
            
            entityCarnetCheques!.name = Localizations.PaymentMethod.Check
            entityCarnetCheques!.prefix = "CH"
            entityCarnetCheques!.numPremier = 1_000
            entityCarnetCheques!.numSuivant = 1_000
            entityCarnetCheques!.nbCheques = 25
            entityCarnetCheques!.account = currentAccount
            entityCarnetCheques!.uuid = UUID()
        }
    }
}
