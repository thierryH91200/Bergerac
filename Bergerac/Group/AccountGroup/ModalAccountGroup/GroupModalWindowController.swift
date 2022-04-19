import AppKit

final class GroupModalWindowController: NSWindowController, NSTextFieldDelegate {

    @IBOutlet weak var nameGroup: NSTextField!
    @IBOutlet weak var mode: NSButton!
    
    @IBOutlet weak var buttonOK: NSButton!
    
    var account :  EntityAccount?
    var edition = false

    override func windowDidLoad() {
        super.windowDidLoad()
        
        buttonOK.isEnabled = true
        nameGroup.delegate = self

        mode.isBordered = false //Important
        mode.title = Localizations.Transaction.ModeCreation
        mode.bezelStyle = .texturedSquare
        mode.wantsLayer = true
        mode.layer?.backgroundColor = NSColor.green.cgColor
        
        if edition == true {

            nameGroup.stringValue = account?.name ?? "name"
            
            mode.title = Localizations.Transaction.ModeEdition
            mode.layer?.backgroundColor = NSColor.orange.cgColor
        }
    }
    
    override var windowNibName: NSNib.Name? {
        return "GroupModalWindowController"
    }

    @IBAction func didTapCancelButton(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        self.window!.close()
    }
    
    @IBAction func didTapDoneButton(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        self.window!.close()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        if nameGroup.stringValue.isEmpty {
            buttonOK.isEnabled = false
        } else {
            buttonOK.isEnabled = true
        }
    }
    

    
}
