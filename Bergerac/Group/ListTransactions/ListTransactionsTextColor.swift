import AppKit

//var groupedSorted = [ (key: String, value:  [ String :  [IdOperations]])]()

// MARK: NSTableViewDelegate
extension ListTransactionsController {
    
    func colorText (quake: EntityTransactions, textField: NSTextField)
    {        
        let type = Defaults.string(forKey: "choix couleurs") ?? "recette/depense"
        let typeOfColor = TypeOfColor(rawValue: type)
        textField.textColor = .labelColor

        switch typeOfColor {
        case .unie:
            textField.textColor = .labelColor

        case .income:
                if quake.amount >= 0.0 {
                    textField.textColor = .green
                } else {
                    textField.textColor = .red
                }
            
        case .rubrique:
            let sousOperations = quake.sousOperations?.allObjects as! [EntitySousOperations]
            textField.textColor = sousOperations.first?.category?.rubric?.color as? NSColor
            
        case .statut:
            let color = Statut.TypeOfStatut(rawValue: Int16(quake.statut))!.color
            textField.textColor = color
            break

        case .mode:
            let color = quake.paymentMode?.color as? NSColor
            textField.textColor = color
            
        case .none:
            textField.textColor = .labelColor
        }
        
    }
    
    func colorSousOperations (quake: EntitySousOperations, textField: NSTextField, propertyEnum: ListeOperationsDisplayProperty) {
        
        let type = Defaults.string(forKey: "choix couleurs") ?? "recette/depense"
        let typeOfColor = TypeOfColor(rawValue: type)
        
        switch typeOfColor {
        case .unie:
            textField.textColor = .labelColor
            
        case .income:
            switch propertyEnum {
            
            case .depense, .amount, .recette, .solde:
                if quake.amount >= 0.0 {
                    textField.textColor = .green
                } else {
                    textField.textColor = .red
                }
                
            default:
                break
            }
            
        case .rubrique:
            textField.textColor = quake.category?.rubric?.color as? NSColor
            
        case .statut:
            break
            
        case .mode:
            break
            
        case .none:
            textField.textColor = .labelColor
        }
    }
}
