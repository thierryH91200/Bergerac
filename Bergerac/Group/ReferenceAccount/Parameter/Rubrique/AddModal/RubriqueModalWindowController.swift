import AppKit

final class RubriqueModalWindowController: NSWindowController {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var colorWell: ComboColorWell!
    
    @IBOutlet weak var cancel: NSButton!
    
    @IBOutlet weak var mode: NSButton!
    
    var edition = false
    var nameRubrique = "new Rubrique"
    var colorRubrique = NSColor.green
    
    override var windowNibName: NSNib.Name? {
        return "RubriqueModalWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
                
        mode.bezelStyle = .texturedSquare
        mode.isBordered = false //Important
        mode.wantsLayer = true
        
        if edition == true {
            
            mode.title = Localizations.Transaction.ModeEdition
            mode.layer?.backgroundColor = NSColor.orange.cgColor
        }
        else {
            mode.title = Localizations.Transaction.ModeCreation
            mode.layer?.backgroundColor = NSColor.orange.cgColor
        }
        
        name.stringValue = nameRubrique
        colorWell.color = colorRubrique

        if cancel.acceptsFirstResponder {
            self.window?.makeFirstResponder(cancel)
        }
    }

    @IBAction func didTapDoneButton(_ sender: Any) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK )
        
        self.window!.close()
        NSColorPanel.shared.orderOut(nil)
    }
    
    @IBAction func didTapCancelButton(_ sender: Any ) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)

        self.window!.close()
        NSColorPanel.shared.orderOut(nil)
    }

}
