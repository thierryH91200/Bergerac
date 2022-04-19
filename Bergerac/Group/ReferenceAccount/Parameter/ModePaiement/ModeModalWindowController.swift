import AppKit

final class ModeModalWindowController: NSWindowController {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var colorWell: NSColorWell!
    
    @IBOutlet weak var cancel: NSButton!

    @IBOutlet weak var mode: NSButton!
    
    var edition = false
    var namePaiement = "new Rubrique"
    var colorPaiement = NSColor.green
    
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
        
        name.stringValue = namePaiement
        colorWell.color = colorPaiement
        
        if cancel.acceptsFirstResponder {
            self.window?.makeFirstResponder(cancel)
        }
    }
    
    override var windowNibName: NSNib.Name? {
        return "ModeModalWindowController"
    }
    
    @IBAction func didTapCancelButton(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        
        self.window!.close()
        NSColorPanel.shared.orderOut(nil)

    }
    
    @IBAction func didTapDoneButton(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        
        self.window!.close()
        NSColorPanel.shared.orderOut(nil)
    }
}
