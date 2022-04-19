import AppKit

final class KSRetailCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var itemImageView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
            super.representedObject = representedObject
            
            if let rep = representedObject as? [String: String] {
                if let key = rep["itemImage"] {
                    
                    let image = Image.shared.getImage(name: key)

                    itemImageView?.image = image
                    itemImageView?.image?.isTemplate = true
                    itemImageView.wantsLayer = true
                    itemImageView.layer?.backgroundColor = NSColor.clear.cgColor
                    
                    label.stringValue = rep["itemTitle"]!
                }
            }
        }
    }
                    
    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 5.0 : 0.0
            view.layer?.borderColor = NSColor.black.cgColor
        }
    }

}
