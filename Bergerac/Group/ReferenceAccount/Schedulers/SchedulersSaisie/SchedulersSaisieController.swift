import AppKit
import SwiftDate
//import TFDate

class Foo: NSObject {
    @objc dynamic var bar = ""
}

public protocol SchedulersSaisieDelegate
{
    func editionData(_ quake: EntitySchedule)
    func razData()
}

final class SchedulersSaisieController: NSViewController, NSTextFieldDelegate, NSControlTextEditingDelegate, NSDatePickerCellDelegate {
    
    public var delegate: EcheanciersDelegate?
    
    @IBOutlet weak var modeOperation: NSButton!
    @IBOutlet weak var modeOperation2: NSButton!
    
    @IBOutlet weak var libelle: NSTextField!
    
    @IBOutlet weak var dateDebut: NSDatePicker!
    @IBOutlet weak var dateFin: NSDatePicker!
    @IBOutlet weak var dateValeur: NSDatePicker!

    @objc var date1: Date?
    @objc var date2: Date?
    @objc var date3: Date?

    @IBOutlet weak var occurence: NSTextField!
    @IBOutlet weak var frequence: NSTextField!
    @IBOutlet weak var popUpFrequence: NSPopUpButton!
    
    @IBOutlet weak var popUpTransfert: NSPopUpButton!
    @IBOutlet weak var popUpCategorie: NSPopUpButton!
    @IBOutlet weak var popUpModePaiement: NSPopUpButton!
    @IBOutlet weak var popUpRubrique: NSPopUpButton!
    
    @IBOutlet weak var montant: NSTextField!
    
    @IBOutlet weak var account: NSTextField!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var surname: NSTextField!
    @IBOutlet weak var number: NSTextField!
    
    @IBOutlet weak var signeMontant: NSButton!
    var categories = [EntityCategory]()
    var entityRubriques = [EntityRubric]()
    var modesPaiement = [EntityPaymentMode]()
    var entitySchedule: EntitySchedule?
    var entityPreference: EntityPreference?
    var entityCompteTransfert: EntityAccount?
    var entityOperationsTransfert: EntityTransactions?

    var dateDeb1 = Date()
    var dateFin1 = Date()

    var edition = false
    
    var foo = Foo()
    var token: NSKeyValueObservation?
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .updateAccount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeOperation.bezelStyle = .texturedSquare
        modeOperation.isBordered = false //Important
        modeOperation.wantsLayer = true
        
        modeOperation2.bezelStyle = .texturedSquare
        modeOperation2.isBordered = false //Important
        modeOperation2.wantsLayer = true
        
        NotificationCenter.receive( self, selector: #selector(updateChangeAccount(_:)), name: .updateAccount)

        dateDebut.delegate = self
        dateFin.delegate = self
        frequence.delegate = self
        occurence.delegate = self
                
        token = foo.observe(\.bar, options: [.new, .old]) { [weak self] _, change in
            if change.oldValue != change.newValue {
                self?.edit()
            }
        }
        
//        dateDebut.allowEmptyDate = false
//        dateDebut.showPromptWhenEmpty = false
//        dateDebut.referenceDate = Date()
//        dateDebut.dateFieldPlaceHolder = ""
        dateDebut.dateValue = Date()
        
//        dateFin.allowEmptyDate = false
//        dateFin.showPromptWhenEmpty = false
//        dateFin.referenceDate = Date()
//        dateFin.dateFieldPlaceHolder = ""
        dateFin.dateValue = Date()

//        dateValeur.allowEmptyDate = false
//        dateValeur.showPromptWhenEmpty = false
//        dateValeur.referenceDate = Date()
//        dateValeur.dateFieldPlaceHolder = ""
        dateValeur.dateValue = Date()
        
        razData()
    }
    
    @objc func updateChangeAccount(_ notification: Notification) {
        
        razData()
    }
    
    @IBAction func popUpFrequenceAction(_ sender: Any) {
        foo.bar = "popUpFrequence"
    }
    
    func edit () {
        
        let changeText = foo.bar
        
        if changeText != "" {
            
            switch changeText {
            case "dateDebut", "frequence", "occurence", "popUpFrequence":
                let numOccurence = Int(occurence.intValue)
                let numFrequence = Int(frequence.intValue)
                let nombre = (numFrequence * numOccurence) - numFrequence
                
                let indexPop = popUpFrequence.indexOfSelectedItem
                switch indexPop {
                case 0:
                    dateFin.dateValue = dateDeb1 + nombre.days
                case 1:
                    dateFin.dateValue = dateDeb1 + nombre.weeks
                case 2:
                    dateFin.dateValue = dateDeb1 + nombre.months
                case 3:
                    dateFin.dateValue = dateDeb1 + nombre.years
                default:
                    dateFin.dateValue = dateDeb1 + nombre.months
                }
                
            case "dateFin":
                print("\(changeText) : *** Error ***")
                
            default:
                print("\(changeText) : \(dateDebut.dateValue)    \(dateFin.dateValue)   \(frequence.stringValue) ")
            }
            foo.bar = ""
        }
    }
    
    func controlTextDidChange(_ notification: Notification) {
        
        guard let textField = notification.object as? NSTextField else { return  }
        
        if textField == frequence {
            foo.bar = "frequence"
        }
        if textField == occurence {
            foo.bar = "occurence"
        }
    }
    
    func datePickerCell(_ datePickerCell: NSDatePickerCell, validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>, timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?) {
        
        let changeText = foo.bar
        guard changeText == "" else { return}
        
        if datePickerCell == dateDebut.cell {
            
            dateDeb1 = proposedDateValue.pointee as Date
            foo.bar = "dateDebut"
        }
        
        if datePickerCell == dateFin.cell {
            
            let dateFin1 = proposedDateValue.pointee as Date
            
            let date2 = dateDebut.dateValue
            var numFrequence = Int(frequence.intValue)
            if numFrequence == 0 { numFrequence = 1 }
            
            let indexPop = popUpFrequence.indexOfSelectedItem
            var date3 = Date()
            switch indexPop {
            case 0:
                let num = dateFin1.days(from: date2) != 0 ? dateFin1.days(from: date2) : 1

                let numOccurence = num / numFrequence
                occurence.intValue = Int32(numOccurence)
                let nombre = (numFrequence * numOccurence) - numFrequence
                date3 = date2 + nombre.days
            case 1:
                var num = dateFin1.weeks(from: date2)
                if num == 0 {
                    num = 1
                }
                let numOccurence = num / numFrequence
                occurence.intValue = Int32(numOccurence)
                let nombre = (numFrequence * numOccurence) - numFrequence
                date3 = date2 + nombre.weeks
            case 2:
                var num = dateFin1.months(from: date2)
                if num == 0 {
                    num = 1
                }
                let numOccurence = num / numFrequence
                occurence.intValue = Int32(numOccurence)
                let nombre = (numFrequence * numOccurence) - numFrequence
                date3 = date2 + nombre.months
            case 3:
                var num = dateFin1.years(from: date2)
                if num == 0 {
                    num = 1
                }
                let numOccurence = num / numFrequence
                occurence.intValue = Int32(numOccurence)
                let nombre = (numFrequence * numOccurence) - numFrequence
                date3 = date2 + nombre.years
            default:
                var num = dateFin1.months(from: date2)
                if num == 0 {
                    num = 1
                }
                let numOccurence = num / numFrequence
                occurence.intValue = Int32(numOccurence)
                let nombre = (numFrequence * numOccurence) - numFrequence
                date3 = date2 + nombre.months
                
            }
            proposedDateValue.pointee =  date3 as NSDate
        }
    }
    
    @IBAction func enregistrerAction(_ sender: Any) {
        
        let context = mainObjectContext
        
        if edition == false
        {
            entitySchedule = NSEntityDescription.insertNewObject(forEntityName: "EntitySchedule", into: context!) as? EntitySchedule

            entitySchedule?.dateCree = Date()
            entitySchedule?.account = currentAccount
            entitySchedule?.nextOccurence = 0
        }
        entitySchedule?.dateModifie   = Date()
        
        entitySchedule?.libelle       = libelle.stringValue
        
        let signe = signeMontant.state.rawValue
        let valeurMontant = montant.doubleValue
        entitySchedule?.amount       = signe == 0 ? valeurMontant : -valeurMontant

        entitySchedule?.dateDebut     = dateDebut.dateValue.noon
        entitySchedule?.dateFin       = dateFin.dateValue.noon
        entitySchedule?.dateValeur    = dateValeur.dateValue.noon
        entitySchedule?.occurence     = Int16(occurence.intValue)
        entitySchedule?.frequence     = Int16(frequence.intValue)
        let typeFrequence             = popUpFrequence.indexOfSelectedItem
        entitySchedule?.typeFrequence = Int16(typeFrequence)
        
        var menuItem = popUpCategorie.selectedItem
        let entity = menuItem?.representedObject as! EntityCategory
        entitySchedule?.category = entity
        
        menuItem = popUpModePaiement.selectedItem
        let entity2 = menuItem?.representedObject as! EntityPaymentMode
        entitySchedule?.paymentMode = entity2

        entitySchedule?.uuid          = UUID()
        
        menuItem = popUpTransfert.selectedItem
        let title = menuItem?.title ?? ""

        if title != "(no transfert)" {
            let compte = menuItem?.representedObject as! EntityAccount
            entitySchedule?.compteLie = compte
        }

        delegate?.updateData()
        razData()
    }
    
    @IBAction func annulerAction(_ sender: NSButton) {
        razData()
    }
    
    @IBAction func actionSigne(_ sender: NSButton) {
        
        if sender.state == .on {
            montant.textColor = NSColor.red
        } else {
            montant.textColor = NSColor.green
        }
    }
    
}

