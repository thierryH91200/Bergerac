import AppKit

final class CategorieModalWindowController: NSWindowController {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var objectif: NSTextField!
    
    @IBOutlet weak var cancel: NSButton!

    @IBOutlet weak var mode: NSButton!
    
    var edition = false
    var nameCategory = "new Category"
    var objectifCategory = 0.0

    override var windowNibName: NSNib.Name? {
        return "CategorieModalWindowController"
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
        
        name.stringValue = nameCategory
        objectif.doubleValue = objectifCategory
        
        if cancel.acceptsFirstResponder {
            self.window?.makeFirstResponder(cancel)
        }
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        
        self.window!.close()
        NSColorPanel.shared.orderOut(nil)

    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        
        self.window!.close()
        NSColorPanel.shared.orderOut(nil)

    }

}
