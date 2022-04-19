import AppKit

public protocol EcheanciersDelegate
{
        /// Called when a value has been selected inside the outline.
    func updateData()
}

final class SchedulerViewController: NSViewController {
    
    public var delegate: SchedulersSaisieDelegate?

    @IBOutlet weak var tableViewScheduler: NSTableView!
    
    enum SchedulerDisplayProperty: String {
        case comment
        
        case dateDebut
        case dateFin

        case dateValeur
        case occurence

        case frequency
        case typeFrequence
        
        case modePaiement

        case rubric
        case category

        case amount
    }

    var entitySchedule =  [EntitySchedule]()
    
    let accountPasteboardType = NSPasteboard.PasteboardType(rawValue: "scheduler.account")
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .updateAccount)
        NotificationCenter.remove( self, name: .selectionDidChangeTable)
    }
    
        // -------------------------------------------------------------------------
        //    MARK: - viewWillAppear
        // -------------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.receive(
            self,
            selector: #selector(updateChangeAccount),
            name: .updateAccount)
        
        NotificationCenter.receive(
            self,
            selector: #selector(selectionDidChange),
            name: .selectionDidChangeTable)
    }
    
    override public func viewDidAppear()     {
        super.viewDidAppear()
        view.window!.title = Localizations.General.Scheduler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id = currentAccount?.uuid.uuidString
        self.tableViewScheduler.autosaveName = "saveEcheancier" + (id)!
        self.tableViewScheduler.autosaveTableColumns = true
        
        tableViewScheduler.registerForDraggedTypes([accountPasteboardType])
        updateData()
    }
    
    @objc func updateChangeAccount(_ notification: Notification) {
        updateData()
    }

        // Notification
    @objc func selectionDidChange(_ notification: Notification) {
        
        let tableView = notification.object as? NSTableView
        guard tableView == tableViewScheduler else { return }
        
        let selectedRow = tableViewScheduler.selectedRow
        if selectedRow >= 0 {
            let quake = entitySchedule[selectedRow]
            delegate?.editionData( quake )
            
        } else {
            delegate?.razData()
        }
    }
    
    @IBAction func removeEcheanciers(_ sender: NSButton) {
        let selectedRow = tableViewScheduler.selectedRow
        if selectedRow >= 0 {
            let quake = entitySchedule[selectedRow]
            
            NSAnimationContext.runAnimationGroup({context in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                
                Scheduler.shared.remove(entity: quake )
                self.view.layoutSubtreeIfNeeded()
                
            }, completionHandler: nil)
            updateData()
        }
    }
}

extension SchedulerViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entitySchedule.count
    }
    
    func tableView(_ tableView: NSTableView,
                   pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let account = entitySchedule[row]
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(account.uuid!.uuidString, forType: accountPasteboardType)
        return pasteboardItem
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }
    
        // For the destination table view
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item = info.draggingPasteboard.pasteboardItems?.first,
            let theString = item.string(forType: accountPasteboardType),
            let account = entitySchedule.first(where: { $0.uuid?.uuidString == theString }),
            let originalRow = entitySchedule.firstIndex(of: account)
        else { return false }
        
        var newRow = row
            // When you drag an item downwards, the "new row" index is actually --1. Remember dragging operation is `.above`.
        if originalRow < newRow {
            newRow = row - 1
        }
        
            // Animate the rows
        tableView.beginUpdates()
        tableView.moveRow(at: originalRow, to: newRow)
        tableView.endUpdates()
        
            // Persist the ordering by saving your data model
            //         saveAccountsReordered(at: originalRow, to: newRow)
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let descriptor = tableView.sortDescriptors.first else { return }
        
        let key = descriptor.key!

        sortNumber(key: key, ascending: descriptor.ascending)
        tableView.reloadData()
    }
    
    func sortNumber(key: String, ascending: Bool) {
        
        entitySchedule.sort { (p1, p2) -> Bool in
            var id1 = 0.0
            var id2 = 0.0
            var id3 = ""
            var id4 = ""

            let propertyEnum = SchedulerDisplayProperty(rawValue: key)

            switch propertyEnum {
            case .comment :
                id1 = 0.0
                id3 = p1.libelle!
                id4 = p2.libelle!
                
            case .dateDebut:
                id1 = p1.dateDebut!.timeIntervalSince1970
                id2 = p2.dateDebut!.timeIntervalSince1970
                
            case .dateFin:
                id1 = p1.dateFin!.timeIntervalSince1970
                id2 = p2.dateFin!.timeIntervalSince1970

            case .dateValeur:
                id1 = p1.dateValeur!.timeIntervalSince1970
                id2 = p2.dateValeur!.timeIntervalSince1970
                
            case .occurence:
                id1 = Double(p1.occurence)
                id2 = Double(p2.occurence)

            case .frequency:
                id1 = Double(p1.frequence)
                id2 = Double(p2.frequence)
                
            case .typeFrequence:
                id1 = Double(p1.typeFrequence)
                id2 = Double(p2.typeFrequence)

            case .modePaiement:
                id3 = p1.paymentMode!.name!
                id4 = p2.paymentMode!.name!
                
            case .rubric:
                id3 = p1.category!.rubric!.name!
                id4 = p2.category!.rubric!.name!
                
            case .category:
                id3 = p1.category!.name!
                id4 = p2.category!.name!

            case .amount:
                id1 = p1.amount
                id2 = p2.amount

            default:
                break
            }
            if id3 == "" {
                if ascending == true{
                    return id1 <= id2
                } else {
                    return id2 < id1
                }
            } else {
                if ascending == true{
                    return id3 <= id4
                } else {
                    return id4 < id3
                }
            }
        }
    }
}

extension SchedulerViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellView : CategoryCellView?
        let identifier = tableColumn!.identifier
        switch identifier {
        case .echLibelle :
            cellView = tableView.makeView(withIdentifier: .echLibelle, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = entitySchedule[row].libelle ?? ""
        case .echDateDebut:
            cellView = tableView.makeView(withIdentifier: .echDateDebut, owner: self) as? CategoryCellView
            let time = entitySchedule[row].dateDebut!
            let formatteddate = formatterDate.string(from: time)
            cellView?.textField?.stringValue = formatteddate
        case .echDateFin:
            cellView = tableView.makeView(withIdentifier: .echDateFin, owner: self) as? CategoryCellView
            let time = entitySchedule[row].dateFin ?? Date()
            let formatteddate = formatterDate.string(from: time)
            cellView?.textField?.stringValue = formatteddate
        case .echDateValeur:
            cellView = tableView.makeView(withIdentifier: .echDateValeur, owner: self) as? CategoryCellView
            let time = entitySchedule[row].dateValeur!
            let formatteddate = formatterDate.string(from: time)
            cellView?.textField?.stringValue = formatteddate
        case .echOccurence:
            cellView = tableView.makeView(withIdentifier: .echOccurence, owner: self) as? CategoryCellView
            cellView?.textField?.intValue = Int32(entitySchedule[row].occurence)
        case .echFrequence:
            cellView = tableView.makeView(withIdentifier: .echFrequence, owner: self) as? CategoryCellView
            cellView?.textField?.intValue = Int32(entitySchedule[row].frequence)
        case .echTypeFrequence:
            cellView = tableView.makeView(withIdentifier: .echTypeFrequence, owner: self) as? CategoryCellView
            cellView?.textField?.intValue = Int32(entitySchedule[row].typeFrequence)
        case .echModePaiement:
            cellView = tableView.makeView(withIdentifier: .echModePaiement, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = (entitySchedule[row].paymentMode?.name)!
        case .echRubrique:
            cellView = tableView.makeView(withIdentifier: .echRubrique, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = (entitySchedule[row].category?.rubric!.name ?? "")
        case .echCategorie:
            cellView = tableView.makeView(withIdentifier: .echCategorie, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = (entitySchedule[row].category?.name ?? "")
        case .echMontant:
            cellView = tableView.makeView(withIdentifier: .echMontant, owner: self) as? CategoryCellView
            cellView?.textField?.doubleValue = entitySchedule[row].amount
        case .account:
            cellView = tableView.makeView(withIdentifier: .account , owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = entitySchedule[row].account!.name!
        case .nameAccount:
            cellView = tableView.makeView(withIdentifier: .nameAccount, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = (entitySchedule[row].account?.identity?.name)!
        case .surNameAccount:
            cellView = tableView.makeView(withIdentifier: .surNameAccount, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = (entitySchedule[row].account?.identity?.surName)!
        case .numberAccount:
            cellView = tableView.makeView(withIdentifier: .numberAccount, owner: self) as? CategoryCellView
            cellView?.textField?.stringValue = (entitySchedule[row].account?.initAccount?.codeAccount)!
        default:
            cellView = nil
        }
        cellView?.oldFont = nil
        cellView?.oldColor = nil
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        switch edge {
        case .trailing:
            let flagAction = NSTableViewRowAction(style: .regular, title: "Flag") { (_, _) in
                print("Flag Action")
            }
            
            return [makeDeleteAction(), flagAction]
        case .leading:
            return []
        @unknown default:
            return []
        }
    }
    
    func tableView(_: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    private func makeDeleteAction() -> NSTableViewRowAction {
        let a = NSTableViewRowAction(
            style: .destructive,
            title: "Delete", //NSLocalizedString("TouchBar.Delete", comment: "Touch Bar"),
            handler: removeRowAndRecord
        )
        a.image = NSImage(named: NSImage.touchBarDeleteTemplateName)
        return a
    }
    
    private func removeRowAndRecord(action: NSTableViewRowAction, row: Int) {
        let quake = self.entitySchedule[row]
        
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            Scheduler.shared.remove(entity: quake )
            self.view.layoutSubtreeIfNeeded()
            
        }, completionHandler: nil)
        self.updateData()
    }
}

extension SchedulerViewController: EcheanciersDelegate {
    func updateData() {
        guard currentAccount != nil else { return }
        entitySchedule = Scheduler.shared.getAllDatas()
        tableViewScheduler.reloadData()
    }
}
