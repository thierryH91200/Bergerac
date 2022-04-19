import AppKit

final class ModeOfPaymentViewController: NSViewController
{
    public var delegate: FilterDelegate?
    
    @IBOutlet weak var tablePaiementView: NSTableView!
    @IBOutlet weak var menuLocal: NSMenu!
    
    var modeModalWindowController: ModeModalWindowController!
    var entityPreference: EntityPreference?
    
    var entityModePaiement =  [EntityPaymentMode]()
    
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
            name: .selectionDidChangeTable)
        
        NotificationCenter.receive(
            self,
            selector: #selector(updateChangeAccount),
            name: .updateAccount)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = Localizations.General.Mode_Payment
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tablePaiementView.selectionHighlightStyle = .regular
        updateData()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        
        updateData()
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        
        let tableView = notification.object as? NSTableView
        guard tableView == tablePaiementView else { return }

        let selectedRow = tablePaiementView.selectedRow
        if selectedRow >= 0 {
            let quake = entityModePaiement[selectedRow]
            let label = quake.name!
            
            let p1 = NSPredicate(format: "account == %@", currentAccount!)
            let p2 = NSPredicate(format: "paymentMode.name == %@", label)
            let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])

            let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
            
            delegate?.applyFilter( fetchRequest)
        }
    }
    
    func updateData() {
        guard currentAccount != nil else { return }
        entityModePaiement = PaymentMode.shared.getAllDatas()
        tablePaiementView.reloadData()
    }
    
        // MARK: - Add Mode de Paiement
    @IBAction func addModePaiement(_ sender: Any) {
        
        let context = mainObjectContext
        
        self.modeModalWindowController = ModeModalWindowController()
        let windowAdd = modeModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let name          = self.modeModalWindowController.name.stringValue
                let color         = self.modeModalWindowController.colorWell.color
                
                let entityMode        = NSEntityDescription.insertNewObject(forEntityName: "EntityPaymentMode", into: context!) as! EntityPaymentMode
                entityMode.name       = name
                entityMode.color     = color
                
                entityMode.uuid = UUID()
                entityMode.account = currentAccount
                
            case .cancel:
                break
                
            default:
                break
            }
            self.modeModalWindowController = nil
        })
    }
    
    @IBAction func editModePaiement(_ sender: Any) {
        
        let selectRow = tablePaiementView.selectedRow
        guard selectRow != -1 else { return }
        let entityMode = entityModePaiement[ selectRow]
        
        self.modeModalWindowController = ModeModalWindowController()
        modeModalWindowController.edition = true
        modeModalWindowController.namePaiement = entityMode.name ?? ""
        modeModalWindowController.colorPaiement = entityMode.color as! NSColor
        
        let windowAdd = modeModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                entityMode.name      = self.modeModalWindowController.name.stringValue
                entityMode.color     = self.modeModalWindowController.colorWell.color
                self.tablePaiementView.reloadData()
                
            case .cancel:
                break
                
            default:
                break
            }
            self.modeModalWindowController = nil
        })
    }
    
    @IBAction func removeModePaiement(_ sender: Any) {
        
        let selectedRows = tablePaiementView.selectedRowIndexes
        guard selectedRows.isEmpty == false else { return }
        
        self.entityPreference = Preference.shared.getAllDatas()
        
        let alertSuppressionKey = "AlertSuppressionMode"
        let defaults = UserDefaults.standard

        
        for selectedRow in selectedRows {
            
            let selectedModePaiement = self.entityModePaiement[selectedRow]
            
            if self.entityPreference?.paymentMode == selectedModePaiement {
                let alert = NSAlert()
                alert.alertStyle = NSAlert.Style.critical
                alert.icon = nil
                alert.messageText = "Impossible select = preference"
                alert.runModal()
                continue
            }
            
            if defaults.bool(forKey: alertSuppressionKey) == true {
                let newModePaiement = (self.entityPreference?.paymentMode)!
                self.changeModePaiement(oldModePaiement: selectedModePaiement, newModePaiement: newModePaiement )
                self.removeMode(modePayement: selectedModePaiement)
                continue
            }

            let alert = NSAlert()
            alert.messageText = Localizations.Mode.MessageText
            alert.informativeText = Localizations.Mode.InformativeText
            alert.addButton(withTitle: Localizations.Mode.Delete)
            alert.addButton(withTitle: Localizations.General.Cancel)
            alert.alertStyle = NSAlert.Style.informational
            alert.showsSuppressionButton = defaults.bool(forKey: alertSuppressionKey)

            alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                    
                    if let suppressionButton = alert.suppressionButton,
                       suppressionButton.state == .on {
                        defaults.set(true, forKey: alertSuppressionKey)
                    }

                    let newModePaiement = (self.entityPreference?.paymentMode)!
                    self.changeModePaiement(oldModePaiement: selectedModePaiement, newModePaiement: newModePaiement )
                    self.removeMode(modePayement: selectedModePaiement)
                }
            })
        }
    }
    
    func removeMode(modePayement: EntityPaymentMode) {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            
            tablePaiementView.beginUpdates()
            PaymentMode.shared.remove(entity: modePayement )
            self.view.layoutSubtreeIfNeeded()
            self.updateData()
            self.tablePaiementView.reloadData()
            tablePaiementView.endUpdates()

            
        }, completionHandler: nil)
    }
    
    func changeModePaiement(oldModePaiement: EntityPaymentMode, newModePaiement: EntityPaymentMode) {
        var listeOperations = [EntityTransactions]()
        
        let context = mainObjectContext

        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "paymentMode.name == %@", oldModePaiement.name!)
        let predicate = NSCompoundPredicate(type: .and , subpredicates: [p1, p2])
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        
        do {
            listeOperations = try context!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        for listeOperation in listeOperations {
            listeOperation.paymentMode = newModePaiement
        }
    }
    
    @IBAction func changeCouleur(_ sender: NSColorWell)
    {
        let row = tablePaiementView.row(for: sender as NSView)
        guard  row != -1 else { return }
        
        let color = sender.color
        let item = entityModePaiement[row]
        item.color = color
        
        let select: IndexSet = [row]
        tablePaiementView.selectRowIndexes(select, byExtendingSelection: false)
    }
}

extension ModeOfPaymentViewController:  NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entityModePaiement.count
    }
}

extension ModeOfPaymentViewController:  NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        switch identifier {
        case .mpName :
            let result = tableView.makeView(withIdentifier: .mpName, owner: self) as! NSTableCellView
            result.textField?.stringValue = entityModePaiement[row].name!
            return result
            
        case .account:
            let result = tableView.makeView(withIdentifier: .account , owner: self) as! NSTableCellView
            result.textField?.stringValue = entityModePaiement[row].account!.name!
            return result
            
        case .mpColor:
            let result = tableView.makeView(withIdentifier: .mpColor, owner: self) as! KSHeaderCellView4
            result.colorWell.color = entityModePaiement[row].color as! NSColor
            return result
            
        case .nameAccount:
            let result = tableView.makeView(withIdentifier: .nameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityModePaiement[row].account?.identity?.name)!
            return result
            
        case .surNameAccount:
            let result = tableView.makeView(withIdentifier: .surNameAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityModePaiement[row].account?.identity?.surName)!
            return result
            
        case .numberAccount:
            let result = tableView.makeView(withIdentifier: .numberAccount, owner: self) as! NSTableCellView
            result.textField?.stringValue = (entityModePaiement[row].account?.initAccount?.codeAccount)!
            return result
            
        default:
            return nil
            
        }
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        let action = NSTableViewRowAction(
            style: .destructive,
            title: "Delete") { (action, row) in
                let quake = self.entityModePaiement[row]
                PaymentMode.shared.remove(entity: quake )
                
                self.tablePaiementView.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
            }
        return [action]
    }
    
}

