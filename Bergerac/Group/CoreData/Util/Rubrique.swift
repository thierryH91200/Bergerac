import AppKit

final class Rubric : NSObject {
    
    fileprivate enum RubriqueDisplayProperty: String {
        case name
        case color
    }
    
    static let shared = Rubric()
    private var entitiesRubric = [EntityRubric]()
    
    var viewContext : NSManagedObjectContext?
    
    override init () {
        if let context = mainObjectContext
        {
            self.viewContext = context
        }
    }
    
    func findOrCreate ( account: EntityAccount,  name: String, color: NSColor, uuid: UUID) -> EntityRubric {
        
        var entityRubric = find( account: account, name: name )
        if entityRubric == nil {
            entityRubric = NSEntityDescription.insertNewObject(forEntityName: "EntityRubric", into: viewContext!) as? EntityRubric
            entityRubric!.name = name
            entityRubric!.color = color
            entityRubric!.uuid = UUID()
            entityRubric!.account = account
        }
        return entityRubric!
    }
    
    func find( account: EntityAccount = currentAccount!, name: String) -> EntityRubric? {
        
        let p1 = NSPredicate(format: "account == %@", account)
        let p2 = NSPredicate(format: "name == %@", name)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
        
        let fetchRequest = NSFetchRequest<EntityRubric>(entityName: "EntityRubric")
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
    
    func remove(entity: EntityRubric)
    {
        viewContext!.undoManager?.beginUndoGrouping()
        viewContext!.undoManager?.setActionName("DeleteRubrique")
        viewContext!.delete(entity)
        viewContext!.undoManager?.endUndoGrouping()
    }
    
    @discardableResult
    func getAllDatas() -> [EntityRubric] {
        
        guard currentAccount != nil else { return [] }
        
        do {
            let fetchRequest = NSFetchRequest<EntityRubric>(entityName: "EntityRubric")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let predicate = NSPredicate(format: "account == %@", currentAccount!)
            fetchRequest.predicate = predicate
            
            entitiesRubric = try viewContext!.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        
        defaultEntity()
        return entitiesRubric
    }
    
    fileprivate func addRubric(_ key: [String : String]) {
        if entitiesRubric.isEmpty == true {
            
            let entityRubric = NSEntityDescription.insertNewObject(forEntityName: "EntityRubric", into: viewContext!) as! EntityRubric
            
            entityRubric.name = key["rubrique"]
            let color = Color.init(rawValue: key["color"]!)?.color
            entityRubric.color = color
            entityRubric.uuid = UUID()
            entityRubric.account = currentAccount
            
            let entityCategory = NSEntityDescription.insertNewObject(forEntityName: "EntityCategory", into: viewContext!) as! EntityCategory
            entityCategory.name = key["categorie"]
            entityCategory.objectif = Double(key["objectif"] ?? "0.0")!
            entityCategory.uuid = UUID()
            entityCategory.rubric = entityRubric
            
            entityRubric.category?.adding(entityCategory)
        } else {
            
            let entityCategory = NSEntityDescription.insertNewObject(forEntityName: "EntityCategory", into: viewContext!) as! EntityCategory
            entityCategory.name = key["categorie"]
            entityCategory.objectif = Double(key["objectif"] ?? "0.0")!
            entityCategory.uuid = UUID()
            entityCategory.rubric = entitiesRubric[0]
            
            entitiesRubric[0].category?.adding(entityCategory)
        }
    }
    
    func defaultEntity()
    {
        if entitiesRubric.isEmpty == true {
            var content = ""
            do {
                let url = Bundle.main.url(forResource: "rubrique", withExtension: "csv")
                content =  try String(contentsOf: url!)
            } catch {
                print(error)
            }
            
            let csv = CSwiftV(with: content, separator: ";", replace: "\r")
            let keys = csv.keyedRows
            if let keys = keys
            {
                for key in keys
                {
                    do {
                        let p1 = NSPredicate(format: "account == %@", currentAccount!)
                        let p2 = NSPredicate(format: "name == %@", key["rubrique"]!)
                        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
                        
                        let fetchRequest = NSFetchRequest<EntityRubric>(entityName: "EntityRubric")
                        fetchRequest.predicate = predicate
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                        
                        entitiesRubric = try viewContext!.fetch(fetchRequest)
                    } catch {
                        print("Error fetching data from CoreData")
                    }
                    addRubric(key)
                }
            }
            do {
                let p1 = NSPredicate(format: "account == %@", currentAccount!)
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
                
                let fetchRequest = NSFetchRequest<EntityRubric>(entityName: "EntityRubric")
                fetchRequest.predicate = predicate
                
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: RubriqueDisplayProperty.name.rawValue, ascending: true)]
                entitiesRubric = try viewContext!.fetch(fetchRequest)
            } catch {
                print("Error fetching data from CoreData")
            }
        }
    }
    
    enum Color: String {
        case black
        case blue
        case brown
        case gray
        case green
        case orange
        case darkGray
        case purple
        case red
        case yellow
        
        var color: NSColor {
            switch self {
            case .red:
                return .red
            case .blue:
                return .blue
            case .green:
                return .green
            case .black:
                return .black
            case .purple:
                return .purple
            case .orange:
                return .orange
            case .brown:
                return .brown
            case .darkGray:
                return .darkGray
            case .yellow:
                return .yellow
            case .gray:
                return .gray
            }
        }
    }
    
}
