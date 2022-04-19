import AppKit

final class PersonViewController: NSViewController, Preferenceable {
    
    let toolbarItemTitle = "List"
    let toolbarItemIcon = NSImage(named: NSImage.listViewTemplateName)!
    
    @IBOutlet var reverseSignAmountCheckBbox: NSButton!
    
    let defaults = UserDefaults.standard



    override var nibName: NSNib.Name? {
        return  "PersonViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
