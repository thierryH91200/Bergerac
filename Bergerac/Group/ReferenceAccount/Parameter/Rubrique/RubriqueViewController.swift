import Cocoa

final class RubriqueViewController: NSViewController {
    
    public var delegate: FilterDelegate?

    @IBOutlet weak var anOutlineView: NSOutlineView!
    @IBOutlet var anTreeController: NSTreeController!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var dragType = [NSPasteboard.PasteboardType]()
    var draggedNode: Any?
    @IBOutlet weak var addRubric: NSButton!
    @IBOutlet weak var removeRubric: NSButton!
    
    @IBOutlet weak var addCategory: NSButton!
    @IBOutlet weak var removeCategory: NSButton!

    var selectIndex = [1]
    var i = 0
    var j = 0

    @objc var managedObjectContext: NSManagedObjectContext = mainObjectContext
    @objc dynamic var customSortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
    
    var rubriqueModalWindowController: RubriqueModalWindowController!
    var categorieModalWindowController: CategorieModalWindowController!
    
        // -------------------------------------------------------------------------------
        //    viewWillAppear
        // -------------------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
            // listen for selection changes from the NSOutlineView inside MainWindowController
            // note: we start observing after our outline view is populated so we don't receive unnecessary notifications at startup
        NotificationCenter.receive(
            self,
            selector: #selector(selectionDidChange(_:)),
            name: .selectionDidChangeOutLine)
        
        NotificationCenter.receive(
            self,
            selector: #selector(updateChangeCompte(_:)),
            name: .updateAccount)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = Localizations.General.Rubric
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateData()
        
        anOutlineView.allowsEmptySelection = false
        let descriptorName = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        anOutlineView.tableColumns[0].sortDescriptorPrototype = descriptorName

        dragType = [NSPasteboard.PasteboardType( "DragType")]
        anOutlineView.registerForDraggedTypes(dragType)
        
        anOutlineView.doubleAction = #selector(doubleClicked)
        anTreeController.sortDescriptors = customSortDescriptors
        
        addRubric.isEnabled      = false
        removeRubric.isEnabled   = false
        addCategory.isEnabled    = false
        removeCategory.isEnabled = false
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        updateData()
    }

    func updateData() {
        guard currentAccount != nil else { return }
                
        Rubric.shared.getAllDatas()
        anTreeController.fetchPredicate = NSPredicate(format: "account == %@", currentAccount!)
        anTreeController.rearrangeObjects()
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.anOutlineView.expandItem(nil, expandChildren: true)
            DispatchQueue.main.async(execute: {() -> Void in
                self.perform(#selector(self.ExpandAll), with: nil, afterDelay: 0.0)
            })
        })
    }
    
    /// Called when the a row in the sidebar is double clicked
    @objc private func doubleClicked(_ sender: Any?) {
        let clickedRow = anOutlineView.item(atRow: anOutlineView.clickedRow)
        
        if anOutlineView.isItemExpanded(clickedRow) {
            anOutlineView.collapseItem(clickedRow)
        } else {
            anOutlineView.expandItem(clickedRow)
        }
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        
        var p2 = NSPredicate()
        
        i += 1
        print("selectionDidChange anOutlineView : ", i)
        
        let sideBar = notification.object as? NSOutlineView
        guard sideBar == anOutlineView else { return }

        let selected = self.anOutlineView.selectedRow
        guard selected != -1 else { return }
        let rowView = anOutlineView.rowView(atRow: selected, makeIfNecessary: false)
        rowView?.isEmphasized = true

        let item = self.anOutlineView.item(atRow: selected)
        let treeNode = item as? NSTreeNode
        let managedObject = treeNode?.representedObject as? NSManagedObject

        var name = ""

        if managedObject is EntityRubric {
            addRubric.isEnabled = true
            removeRubric.isEnabled = true
            addCategory.isEnabled = false
            removeCategory.isEnabled = false
            
            name = (managedObject as? EntityRubric)!.name!
            p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name == %@).@count > 0", name)

        } else {
            addRubric.isEnabled = false
            removeRubric.isEnabled = false
            addCategory.isEnabled = true
            removeCategory.isEnabled = true
            
            name = (managedObject as? EntityCategory)!.name!
            p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.name == %@).@count > 0", name)
        }

        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]

        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate?.applyFilter( fetchRequest )
        })
    }

}

