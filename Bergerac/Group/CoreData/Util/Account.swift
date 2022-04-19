import AppKit

final class Account : NSObject {
    
    static let shared = Account()
    var entities = [EntityAccount]()
    var viewContext : NSManagedObjectContext?
    
    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    func getAllDatas() -> [EntityAccount] {
        
        do {
            entities = try viewContext!.fetch(EntityAccount.fetchRequest())
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    // MARK: create account
    func create(nameAccount: String, nameImage: String, idName: String, idPrenom: String, numAccount: String) -> EntityAccount {
        let account = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: viewContext!) as! EntityAccount
        account.name = nameAccount
        account.nameImage = nameImage
        account.dateEcheancier = Date().noon
        account.isAccount = true
        account.isRoot = false
        account.uuid = UUID()
        
        let identity = Identity.shared.create(name: idName, prenom: idPrenom)
        identity.account = account
        account.identity = identity
        
        let initAccount = InitAccount.shared.create(numAccount: numAccount)
        initAccount.account = account
        account.initAccount = initAccount
        
        return account
    }
    
    func getRoot() -> [EntityAccount] {
        
        let fetchRequest = NSFetchRequest<EntityAccount>(entityName: "EntityAccount")
        let predicate = NSPredicate(format: "isRoot == true")
        fetchRequest.predicate = predicate
        
        do {
            entities = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        return entities
    }
    
    // just for the debug
    func printAccount(entityAccount: EntityAccount, description: String) {
        let name = entityAccount.name ?? "nameAccount"
        let identity = entityAccount.identity
        let idName = identity?.name ?? "name"
        let idPrenom = identity?.surName ?? "prenom"
        let idNumber = entityAccount.initAccount?.codeAccount ?? "codeAccount"
        
        print("\(description) : \(name) \(idName) \(idPrenom) \(idNumber)")
    }
}
