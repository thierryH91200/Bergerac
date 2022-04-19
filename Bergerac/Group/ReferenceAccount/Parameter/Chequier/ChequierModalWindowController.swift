import AppKit

final class ChequierModalWindowController: NSWindowController {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var prefix: NSTextField!
    @IBOutlet weak var numFirst: NSTextField!
    @IBOutlet weak var numNext: NSTextField!
    @IBOutlet weak var numberCheques: NSTextField!
    
    @IBOutlet weak var mode: NSButton!
    
    var entityCarnetCheques =  EntityCarnetCheques()
    var edition = false
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        mode.wantsLayer = true
        mode.isBordered = false //Important
        mode.bezelStyle = .texturedSquare
        mode.title = Localizations.Transaction.ModeCreation
        mode.layer?.backgroundColor = NSColor.green.cgColor

        if edition == true {
            name.stringValue = entityCarnetCheques.name!
            prefix.stringValue = entityCarnetCheques.prefix!
            numFirst.stringValue = String(entityCarnetCheques.numPremier)
            numNext.stringValue = String(entityCarnetCheques.numSuivant)
            numberCheques.stringValue = String(entityCarnetCheques.nbCheques)
            
            mode.title = Localizations.Transaction.ModeEdition
            mode.layer?.backgroundColor = NSColor.orange.cgColor
        }
    }
    
    override var windowNibName: NSNib.Name? {
        return "ChequierModalWindowController"
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        self.window!.close()
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        self.window!.close()
    }
    
}

