import AppKit

var mainObjectContext: NSManagedObjectContext!
var currentAccount: EntityAccount?
let Defaults = UserDefaults.standard

class Statut : NSObject {
    
    static let shared = Statut()

    enum TypeOfStatut: Int16 {
        case planifie
        case engage
        case realise
        
        var label: String
        {
            switch self {
            case .planifie: return Localizations.Statut.Planifie
            case .engage: return Localizations.Statut.Engaged
            case .realise: return Localizations.Statut.Realise        }
        }
        var color: NSColor
        {
            var attrs = NSColor.green
            switch self {
            case .planifie:
                attrs = .labelColor
            case .engage:
                attrs = .blue
            case .realise:
                attrs = .green
            }
            return attrs
        }
    }
    
    func findStatut ( statut: String) -> Int16 {
        
        if TypeOfStatut(rawValue: 0 )?.label == statut {
            return 0
        }
        if TypeOfStatut(rawValue: 1 )?.label == statut {
            return 1
        }
        if TypeOfStatut(rawValue: 2 )?.label == statut {
            return 2
        }
        return 1
    }
}
