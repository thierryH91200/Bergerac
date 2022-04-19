import AppKit

@objc
public protocol SourceListDelegate
{
    /// Called when a value has been selected inside the outline.
    func changeView(_ name: String)
}

final class SourceListViewController: NSViewController {
    
    public weak var delegate: SourceListDelegate?
    
    @IBOutlet weak var group: NSButton!
    @IBOutlet weak var sidebarOutlineView: NSOutlineView!
    
    var datas       = [Datas]()
    var selectIndex = [1]
    
    var colorBackGround = NSColor.clear
//    var rowSizeStyle: NSTableView.RowSizeStyle  = .default
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.receive( self, selector: #selector(selectionDidChange(_:)), name: .selectionDidChangeOutLine)
        
        sidebarOutlineView.selectRowIndexes([2], byExtendingSelection: false)
        sidebarOutlineView.selectRowIndexes([1], byExtendingSelection: false)
    }

    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .selectionDidChangeOutLine)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedList("Feeds")
        self.reloadData()
    }
    
    func reloadData() {
        
        self.sidebarOutlineView.reloadData()
        self.sidebarOutlineView.expandItem(nil, expandChildren: true)
        self.sidebarOutlineView.selectRowIndexes(IndexSet(selectIndex), byExtendingSelection: false)
    }
    
    func feedList(_ fileName: String) {
        
        let url = Bundle.main.url(forResource: fileName, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        datas = try! data.decoded()
        
        // or
        // datas = try! data.decoded() as [Donnees]

        // or
        // let plistDecoder = PropertyListDecoder()
        // datas = try! plistDecoder.decode([Donnees].self, from: data)
    }
    
    @objc func selectionDidChange(_ notification: Notification)
    {
        let sideBar = notification.object as? NSOutlineView
        guard sideBar == sidebarOutlineView else { return }
        
        let selectedIndex = sidebarOutlineView.selectedRow
        guard selectedIndex != -1 else { return }
        
        if let item = sidebarOutlineView.item(atRow: selectedIndex) as? Children
        {
            delegate?.changeView( item.nameView )
        }
    }

    
}
