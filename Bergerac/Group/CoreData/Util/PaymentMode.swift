import AppKit

final class PaymentMode : NSObject {
    
    static let shared = PaymentMode()
    private var entitiesModePaiement = [EntityPaymentMode]()
    var viewContext : NSManagedObjectContext?

    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }

    func findModePaiement(entity: EntityPaymentMode) -> Int {
        
        let i = entitiesModePaiement.firstIndex { $0 === entity }
        return i!
    }
    
    func findOrCreate ( account: EntityAccount,  name: String, color: NSColor, uuid: UUID) -> EntityPaymentMode {
        
        var entity = find( account: account, name: name )
        if entity == nil {
            entity = create(account: currentAccount!, name: name, color: color)
        }
        return entity!
    }
    
    @discardableResult
    func create ( account: EntityAccount,  name: String, color: NSColor) -> EntityPaymentMode {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityPaymentMode", into: viewContext!) as! EntityPaymentMode
        entity.name = name
        entity.color = color
        entity.uuid = UUID()
        entity.account = account
        return entity
    }
    
    func find( account: EntityAccount = currentAccount!, name: String) -> EntityPaymentMode? {
        
        let p1 = NSPredicate(format: "account == %@", account)
        let p2 = NSPredicate(format: "name == %@", name)
        let predicate = NSCompoundPredicate(type:.and, subpredicates: [p1, p2])
        
        let fetchRequest = NSFetchRequest<EntityPaymentMode>(entityName: "EntityPaymentMode")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let searchResults = try viewContext!.fetch(fetchRequest)
            let result = searchResults.isEmpty == false ? searchResults.first : nil
            return result
        } catch {
            print("Error with request: \(error)")
            return nil
        }
    }
    
    // MARK: - delete ModePaiement
    func remove(entity: EntityPaymentMode)
    {
        viewContext!.undoManager?.beginUndoGrouping()
        viewContext!.undoManager?.setActionName("DeletePaymentMode")
        viewContext!.delete(entity)
        viewContext!.undoManager?.endUndoGrouping()
    }
    
    func loadModePaiement () -> NSPopUpButton {
        let  modePaiementMenu = NSMenu()
        let popModePaiement =  NSPopUpButton()
        
        var modesPaiement = getAllDatas()
        modesPaiement = modesPaiement.sorted { $0.name! < $1.name! }
        for modePaiement in modesPaiement
        {
            modePaiementMenu.addItem(modePaiementItemFor(modePaiement) )
        }
        popModePaiement.menu = modePaiementMenu
        return popModePaiement
    }
    
    fileprivate func modePaiementItemFor(_ value: EntityPaymentMode) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value.name!
        menuItem.action = nil
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    @discardableResult
    func getAllDatas() -> [EntityPaymentMode] {
        
        do {
            let fetchRequest = NSFetchRequest<EntityPaymentMode>(entityName: "EntityPaymentMode")
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            fetchRequest.predicate = predicate
            
            entitiesModePaiement = try viewContext!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        defaultModePaiement()
        return entitiesModePaiement
    }
    
    func defaultModePaiement()
    {
        if entitiesModePaiement.isEmpty == true {
            var name = Localizations.PaymentMethod.Bank_Card
            create(account: currentAccount!, name: name, color : .green)

            name = Localizations.PaymentMethod.Check
            create(account: currentAccount!, name: name, color : .yellow)
            
            name = Localizations.PaymentMethod.Cash
            create(account: currentAccount!, name: name, color : .blue)
            
            name = Localizations.PaymentMethod.Prelevement
            create(account: currentAccount!, name: name, color : .red)
            
            name = Localizations.PaymentMethod.Discount
            create(account: currentAccount!, name: name, color : .gray)

            name = Localizations.PaymentMethod.RetraitEspeces
            create(account: currentAccount!, name: name, color : .orange)
            
            name = Localizations.PaymentMethod.Transfers
            create(account: currentAccount!, name: name, color : .brown)
            
            do {
                let fetchRequest = NSFetchRequest<EntityPaymentMode>(entityName: "EntityPaymentMode")
                let predicate = NSPredicate(format: "account == %@", currentAccount!)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                fetchRequest.predicate = predicate
                
                entitiesModePaiement = try viewContext!.fetch(fetchRequest)
            } catch {
                print("Error fetching data from CoreData")
            }
        }
    }
}
