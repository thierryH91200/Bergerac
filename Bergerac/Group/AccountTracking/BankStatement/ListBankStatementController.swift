    //
    //  BankStatement.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 22/04/2021.
    //  Copyright © 2021 thierry hentic. All rights reserved.
    //

import Cocoa
import PDFKit

final class ListBankStatementController: NSViewController, DragViewDelegate  {
    
    @IBOutlet weak var tableBankStatement: NSTableView!
    
    enum BankStatementDisplayProperty: String {
        case idCol
        
        case dateDebCol
        case soldeDebCol

        case dateInterCol
        case soldeInterCol

        case dateFinCol
        case soldeFinCol
        
        case dateCBCol
        case soldeCBCol

        case pdfCol
    }
    
    public var delegate: FilterDelegate?

    var entityBankStatements : [EntityBankStatement] = []
    var entityBankStatement : EntityBankStatement?
    
    var sendFilename = ""
    
    var bankStatementModalWindowController : BankStatementModalWindowController!
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()

    var urls: [URL] = []
    var url =  URL(string: "")

    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.receive( self, selector: #selector(updateChangeAccount(_:)), name: .updateAccount)
        NotificationCenter.receive( self, selector: #selector(selectionDidChange(_:)), name: .selectionDidChangeTable)
    }

    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .updateAccount)
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = "List Bank Statement"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do view setup here.
        
        tableBankStatement.delegate = self
        tableBankStatement.dataSource = self
        
        let id = currentAccount?.uuid.uuidString
        self.tableBankStatement.autosaveTableColumns = false
        self.tableBankStatement.autosaveName = "saveBankStatement" + (id)!
        self.tableBankStatement.autosaveTableColumns = true
        
        tableBankStatement.doubleAction = #selector(doubleClicked)
        updateData()
    }
    
    func updateData() {
        guard currentAccount != nil else { return }
        entityBankStatements = BankStatement.shared.getAllDatas()
//        for entity in entityBankStatements {
//            BankStatement.shared.remove(entity: entity)
//        }
        tableBankStatement.reloadData()
    }

    @objc func updateChangeAccount(_ notification: Notification) {
        updateData()
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
                
        let tableView = notification.object as? NSTableView
        guard tableView == tableBankStatement else { return }

        let ascending = false
        
        let selectedRow = tableBankStatement.selectedRow
        if selectedRow >= 0 {
            let quake = entityBankStatements[selectedRow]
            let reference = quake.number
            
            let p1 = NSPredicate(format: "account == %@", currentAccount!)
            let p2 = NSPredicate(format: "bankStatement == %f", reference)
            let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2])
            
            let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
            fetchRequest.predicate = predicate
            let s1 = NSSortDescriptor(key: "datePointage", ascending: ascending)
            let s2 = NSSortDescriptor(key: "dateOperation", ascending: ascending)
            fetchRequest.sortDescriptors = [s1, s2]
            
            printTimeElapsedWhenRunningCode(title: "applyFilter") {
                delegate?.applyFilter( fetchRequest)
//            delegate?.applyFilterTmp(reference: reference)
            }
        }
    }
    
    func dragViewDidReceive(fileURLs: [URL])
    {
        if let firstPdfFileURL = fileURLs.first
        {
            print( firstPdfFileURL )
            url = firstPdfFileURL
            urls.append(firstPdfFileURL)
            tableBankStatement.reloadData()
        }
    }
}

extension ListBankStatementController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return entityBankStatements.count
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let descriptor = tableView.sortDescriptors.first else { return }

        let key = descriptor.key!
        sortNumber(key: key, ascending: descriptor.ascending)
        tableView.reloadData()
    }
    
    func sortNumber(key: String, ascending: Bool) {
        
        entityBankStatements.sort { (p1, p2) -> Bool in
            var id1 = 0.0
            var id2 = 0.0
            switch key {
            case "id":
                id1 = p1.number
                id2 = p2.number
                
            case "soldeDeb":
                id1 = p1.soldeDebut
                id2 = p2.soldeDebut
            case "dateDeb":
                id1 = p1.dateDebut!.timeIntervalSince1970
                id2 = p2.dateDebut!.timeIntervalSince1970

            case "soldeInter":
                id1 = p1.soldeInter
                id2 = p2.soldeInter
            case "dateInter":
                id1 = p1.dateInter!.timeIntervalSince1970
                id2 = p2.dateInter!.timeIntervalSince1970

            case "soldeFin":
                id1 = p1.soldeFin
                id2 = p2.soldeFin
            case "dateFin":
                id1 = p1.dateFin!.timeIntervalSince1970
                id2 = p2.dateFin!.timeIntervalSince1970

            case "soldeCB":
                id1 = p1.soldeCB
                id2 = p2.soldeCB
            case "dateCB":
                id1 = p1.dateCB!.timeIntervalSince1970
                id2 = p2.dateCB!.timeIntervalSince1970
                
            default:
                break
            }
            if ascending {
                return id1 <= id2
            } else {
                return id2 < id1
            }
        }
    }
}

extension ListBankStatementController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellView: NSTableCellView?
        let identifier = tableColumn!.identifier
        guard let propertyEnum = BankStatementDisplayProperty(rawValue: identifier.rawValue) else { return nil }

        switch propertyEnum
        {
        case .idCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "idNumCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.doubleValue = entityBankStatements[row].number

        case .dateDebCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "dateDebCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = ""

            if let time = entityBankStatements[row].dateDebut {
                let formattedDate = formatterDate.string(from: time)
                cellView?.textField?.stringValue = formattedDate
            }
            
        case .soldeDebCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "soldeInitCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.doubleValue = entityBankStatements[row].soldeDebut
            
        case .dateInterCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "dateInterCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = ""

            if let time = entityBankStatements[row].dateInter {
                let formattedDate = formatterDate.string(from: time)
                cellView?.textField?.stringValue = formattedDate
            }

        case .soldeInterCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "soldeInterCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.doubleValue = entityBankStatements[row].soldeInter
            
        case .dateFinCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "dateFinCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = ""

            if let time = entityBankStatements[row].dateFin {
                let formattedDate = formatterDate.string(from: time)
                cellView?.textField?.stringValue = formattedDate
            }
            
        case .soldeFinCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "soldeFinCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.doubleValue = entityBankStatements[row].soldeFin
            
        case .dateCBCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "dateCBCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = ""

            if let time = entityBankStatements[row].dateCB {
                let formattedDate = formatterDate.string(from: time)
                cellView?.textField?.stringValue = formattedDate
            }
            
        case .soldeCBCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "soldeCBCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.doubleValue =  entityBankStatements[row].soldeCB
            
        case .pdfCol:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "pdfCell")
            cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            cellView?.textField?.stringValue = ""
            
            let list = entityBankStatements[row] as EntityBankStatement

            if let pdfDoc = list.pdfDoc {
                let pdfDocument = PDFDocument(data: pdfDoc )
                if let firstPage = pdfDocument?.page(at: 0) {
                    cellView?.imageView?.image = firstPage.thumbnail(of: NSSize(width: 256, height: 256), for: .artBox)
                }
            }
            else {
                cellView?.imageView?.image = nil
            }
        }
        return cellView

    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        let action = NSTableViewRowAction(style: .destructive, title: "Delete") { (action, row) in
            self.tableBankStatement.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
        }
        return [action]
    }
    
}
