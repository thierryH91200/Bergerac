import AppKit

// MARK: - Bank
final class Bank : NSObject {
    
    static let shared = Bank()
    var entitiesBank = [EntityBank]()
    
    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }

    func create() -> EntityBank {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityBank", into: viewContext!) as? EntityBank

        entity!.adress = ""
        entity!.bank = ""
        entity!.cp = 0
        entity!.email = ""
        entity!.fonction = ""
        entity!.mobile = ""
        entity!.name = ""
        entity!.country = ""
        entity!.phone = ""
        entity!.town = ""
        entity!.uuid = UUID()
        
        entity!.account = currentAccount
        return entity!
    }
    
    @discardableResult func getAllDatas() -> EntityBank {
        
        do {
            let fetchRequest = NSFetchRequest<EntityBank>(entityName: "EntityBank")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            entitiesBank = try viewContext!.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        if entitiesBank.first != nil {
            return entitiesBank.first!
        } else {
            return create()
        }
    }
}

// MARK: - InitAccount
final class InitAccount : NSObject {
    
    static let shared = InitAccount()
    var entitiesInitAccount = [EntityInitAccount]()

    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    
    func create(numAccount : String = "" ) -> EntityInitAccount {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityInitAccount", into: viewContext!) as? EntityInitAccount
        
        entity!.bic = ""
        entity!.cleRib = ""
        entity!.codeBank = ""
        entity!.codeAccount = numAccount
        entity!.codeGuichet = ""
        entity!.engage = 0
        entity!.iban1 = ""
        entity!.iban2 = ""
        entity!.iban3 = ""
        entity!.iban4 = ""
        entity!.iban5 = ""
        entity!.iban6 = ""
        entity!.iban7 = ""
        entity!.iban8 = ""
        entity!.iban9 = ""
        entity!.prevu = 0
        entity!.realise = 0
        return entity!
    }
    
    @discardableResult func getAllDatas() -> EntityInitAccount {
        
        do {
            let fetchRequest = NSFetchRequest<EntityInitAccount>(entityName: "EntityInitAccount")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            entitiesInitAccount = try viewContext!.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        if entitiesInitAccount.first != nil {
            return entitiesInitAccount.first!
        } else {
            return create()
        }
    }
}

// MARK: - Identite
final class Identity : NSObject {
    
    static let shared = Identity()
    private var entities = [EntityIdentity]()
    
    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    
    func create(name: String = "", prenom: String = "") -> EntityIdentity {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityIdentity", into: viewContext!) as? EntityIdentity
        entity!.name       = name
        entity!.surName    = prenom
        entity!.adress     = ""
        entity!.complement = ""
        entity!.cp         = 0
        entity!.town       = ""
        entity!.phone      = ""
        entity!.country    = ""
        entity!.mobile     = ""
        entity!.email      = ""
        return entity!
    }
    
    @discardableResult func getAllDatas() -> EntityIdentity {
        
        do {
            let fetchRequest = NSFetchRequest<EntityIdentity>(entityName: "EntityIdentity")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            entities = try viewContext!.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        if entities.first != nil {
            return entities.first!
        } else {
            return create()
        }
    }
    
}
