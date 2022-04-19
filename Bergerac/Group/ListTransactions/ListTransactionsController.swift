import AppKit
//import SwiftDate
//import TFDate

// ListTransactionsController -> OperationController
public protocol ListeOperationsDelegate
{
    /// Called when a value has been selected inside the outline.
    func editionOperations(_ quakes: [EntityTransactions])
    func resetOperation()
}

// xxxxController -> ListTransactionsController
public protocol  FilterDelegate
{
    func updateListeTransactions(_ liste: [EntityTransactions])
    func applyFilter(_ fetchRequest: NSFetchRequest<EntityTransactions>)
    func expandAll()
}

final class ListTransactionsController: NSViewController {
    
    public typealias TrackingYear           = [ GroupedYearOperations ]
    public typealias TrackingMonth          = GroupedYearOperations
    public typealias TrackingIdTransactions = GroupedMonthOperations
    public typealias TrackingSubOperations  = Transaction
    public typealias TrackingSubOperation   = EntitySousOperations
       
    enum ListeOperationsDisplayProperty: String {
        case dateTransaction
        case datePointage
        case comment
        case category
        case rubric
        case amount
        case mode
        case bankStatement
        case statut
        case checkNumber
        case depense
        case recette
        case solde
        case liee
    }
    
    enum TypeOfColor: String {
        case unie     = "unie"
        case income   = "recette/depense"
        case rubrique = "rubrique"
        case statut   = "statut"
        case mode     = "mode"
    }
    
    //    private let _undoManager = UndoManager()
    //    override var undoManager: UndoManager {
    //        return _undoManager
    //    }
    
    public var delegate: ListeOperationsDelegate?
    
    @IBOutlet weak var outlineListView: NSOutlineView!
    
    @IBOutlet weak var theBox1: NSBox!
    @IBOutlet weak var theBox2: NSBox!
    @IBOutlet weak var theBox3: NSBox!

    @IBOutlet weak var removeButton: NSButton!
    
    @IBOutlet weak var bankBalance: NSTextField!
    @IBOutlet weak var realBalance: NSTextField!
    @IBOutlet weak var finalBalance: NSTextField!
    
    @IBOutlet weak var soldeBanque : NSTextField!
    @IBOutlet weak var soldeReel: NSTextField!
    @IBOutlet weak var soldeFinal: NSTextField!
    
    @IBOutlet weak var labelInfo: NSTextField!
    @IBOutlet weak var datePicker: NSDatePicker!
    
    @IBOutlet var menuTable: NSMenu!
    
    var secondary = false
    
    var colorBackGround = #colorLiteral(red: 0.8157508969, green: 0.8595363498, blue: 0.9023539424, alpha: 1)
    
    let attribute: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .bold),
        .foregroundColor: NSColor.black]
    
    var listTransactions = [EntityTransactions]()
    
    let formatterPrice: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    /// the key in user defaults
    let kUserDefaultsKeyVisibleColumns = "kUserDefaultsKeyVisibleColumns"
    
    var groupedSorted = [ GroupedYearOperations ]()
    var solde = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.outlineListView.layout()
        outlineListView.usesAutomaticRowHeights = false

        self.outlineListView.selectionHighlightStyle = .regular

        createOutlineContextMenu()
        
        // assuming here you have added the self.imageView to the main view and it was declared before.
        self.outlineListView.translatesAutoresizingMaskIntoConstraints = false

//       // create the constraints with the constant value you want.
//       var verticalSpace = NSLayoutConstraint(item: self.imageView, attribute: .Bottom, relatedBy: .Equal, toItem: self.button, attribute: .Bottom, multiplier: 1, constant: 50)
//
//      // activate the constraints
//      NSLayoutConstraint.activateConstraints([verticalSpace])
        
        bankBalance.stringValue = Localizations.Statut.Realise
        soldeBanque.font = NSFont(name : "Silom", size : 16.0)!
        
        realBalance.stringValue = Localizations.Statut.Planifie
        soldeReel.font   = NSFont(name : "Silom", size : 16.0)!
        
        finalBalance.stringValue = Localizations.Statut.Engaged
        soldeFinal.font  = NSFont(name : "Silom", size : 16.0)!
        
        // vintage playback view
        self.theBox1.contentView?.isHidden = false
        self.theBox1.boxType = .custom
        self.theBox1.borderWidth = 1.1
        self.theBox1.cornerRadius = 3
        self.theBox1.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)

        // vintage playback view
        self.theBox2.contentView?.isHidden = false
        self.theBox2.boxType = .custom
        self.theBox2.borderWidth = 1.1
        self.theBox2.cornerRadius = 3
        self.theBox2.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)

        // vintage playback view
        self.theBox3.contentView?.isHidden = false
        self.theBox3.boxType = .custom
        self.theBox3.borderWidth = 1.1
        self.theBox3.cornerRadius = 3
        self.theBox3.fillColor = NSColor(patternImage: NSImage(named: NSImage.Name( "Gradient"))!)
        
        self.outlineListView.doubleAction = #selector(doubleClicked)
        //        NotificationCenter.default.addObserver(self, selector: #selector(itemWillExpand(_:)), name: NSOutlineView.itemWillExpandNotification, object: self.outlineView);

        self.outlineListView.allowsEmptySelection = true
        
        var name = ""
        if secondary == true {
            name = "save" + "Secondary" + (currentAccount?.uuid.uuidString)!
        }
        else {
            name = "save" + (currentAccount?.uuid.uuidString)!
        }
        self.outlineListView.autosaveTableColumns = true
        self.outlineListView.autosaveName = name
        self.outlineListView.autosaveExpandedItems = true
        self.reloadData()

        outlineListView.menu = menuTable
        
        self.outlineListView.selectRowIndexes([3], byExtendingSelection: false)
        self.outlineListView.selectRowIndexes([1], byExtendingSelection: false)
    }
    
        // -----------------------------------------------------------------------
        //    viewWillAppear
        // listen for selection changes from the NSOutlineView inside MainWindowController
        // note: we start observing after our outline view is populated so we don't receive unnecessary notifications at startup
        // -----------------------------------------------------------------------
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.receive(
            self,
            selector: #selector(updateChangeAccount(_:)),
            name: .updateAccount)
        NotificationCenter.receive(
            self,
            selector: #selector(selectionDidChange(_:)),
            name: .selectionDidChangeOutLine)
        
        let notif = Notification(name: .updateAccount)
        updateChangeAccount(notif)
        
        self.outlineListView.selectRowIndexes([3], byExtendingSelection: false)
        self.outlineListView.selectRowIndexes([1], byExtendingSelection: false)
    }

    override func viewDidAppear()
    {
        super.viewDidAppear()
        view.window?.title = Localizations.General.List_Transactions
        self.resetChange()
    }
    
    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .updateAccount )
        NotificationCenter.remove( self, name: .selectionDidChangeOutLine)
    }
    
    // ------------------------------------------------------------------------
    //    dealloc
    // ------------------------------------------------------------------------
    deinit
    {
//        NotificationCenter.remove(instance: self, name: .selectionDidChangeOutLine)
//        NotificationCenter.remove(instance: self, name: .updateAccount)
    }
    
    @IBAction func datePickerAction(_ sender: Any) {
        let date = datePicker.dateValue
        currentAccount?.dateEcheancier = date
    }

    func setUpDatePicker() {
        self.datePicker.delegate = self
        self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
        self.datePicker.minDate = Date()
    }
    
    // Called when the a row in the sidebar is double clicked
    @objc private func doubleClicked(_ sender: Any?) {
        let clickedRow = outlineListView.item(atRow: outlineListView.clickedRow)
        
        if outlineListView.isItemExpanded(clickedRow) {
            outlineListView.collapseItem(clickedRow)
        } else {
            outlineListView.expandItem(clickedRow)
        }
    }
    
    @objc func updateChangeAccount(_ notification: Notification) {
        
        printTimeElapsedWhenRunningCode(title:"updateChangeAccount ") {
            
            var name = ""
            if secondary == true {
                name = "save" + "Secondary" + (currentAccount?.uuid.uuidString)!
            }
            else {
                name = "save" + (currentAccount?.uuid.uuidString)!
            }            
            self.outlineListView.autosaveExpandedItems = false
            self.outlineListView.autosaveName = name
            
            self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
            self.delegate?.resetOperation()
            
            self.getAllData()
            self.reloadData()
            
            outlineListView.deselectAll(nil)
            self.resetChange()
        }
    }
    
    func resetChange() {
        self.removeButton.isHidden = true

        var amount  = 0.0
        var total   = 0.0
        var expense = 0.0
        var income  = 0.0
        var info    = ""
        var select  = ""
        var number  = 0
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        number = listTransactions.count
        for listTransaction in listTransactions {
            amount = listTransaction.amount
            total += amount
            if amount < 0 {
                expense += amount
            } else {
                income += amount
            }
        }
        
        let strAmount = formatter.string(from: total as NSNumber)!
        let strExpense = formatter.string(from: expense as NSNumber)!
        let strIncome = formatter.string(from: income as NSNumber)!
        
        if number < 2 {
            select =   Localizations.ListTransaction.transaction.singular
        } else {
            select =   Localizations.ListTransaction.transaction.plural(number)
        }
        info = select + "  " + Localizations.ListTransaction.info(strExpense, strIncome, strAmount)
        
        let attributedText = NSAttributedString(string: info, attributes: attribute)
        self.labelInfo.attributedStringValue = attributedText
        
        self.delegate?.resetOperation()
    }
    
    @objc func selectionDidChange(_ notification: Notification) {
        
        let outlineView = notification.object as? NSOutlineView
        guard  outlineView == outlineListView else { return }
        
        let selectedRow = (outlineView?.selectedRowIndexes)!
        let selectRow = (outlineView?.selectedRow)!
        
        guard selectRow != -1 else {
            resetChange()
            return }
        
        let rowView = outlineView?.rowView(atRow: selectRow, makeIfNecessary: false)
        rowView?.isEmphasized = true
        
        if selectedRow.isEmpty == false {
            
            self.removeButton.isHidden = false
            var transactionsSelected = [EntityTransactions]()
            
            var amount = 0.0
            var solde = 0.0
            var expense = 0.0
            var income = 0.0
            var select = ""
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            
            for row in selectedRow {
                let item = outlineView?.item(atRow: row) as? Transaction
                guard item != nil else { return }
                
                transactionsSelected.append((item?.entityTransaction)!)
                
                amount = (item?.entityTransaction.amount)!
                solde += amount
                if amount < 0 {
                    expense += amount
                } else {
                    income += amount
                }
            }
            
            // Info
            let amountStr = formatter.string(from: solde as NSNumber)!
            let strExpense = formatter.string(from: expense as NSNumber)!
            let strIncome = formatter.string(from: income as NSNumber)!
            let count = selectedRow.count
            
            if count < 2 {
                select =   Localizations.ListTransaction.transaction.selectionnee.singular
            } else {
                select =   Localizations.ListTransaction.transaction.selectionnee.plural(count)
            }
            let info = select + Localizations.ListTransaction.info( strExpense, strIncome, amountStr)
            
            let attributedText = NSAttributedString(string: info, attributes: attribute)
            self.labelInfo.attributedStringValue = attributedText
            
            self.delegate?.editionOperations(transactionsSelected)
            self.becomeFirstResponder()
        }
    }
    
    func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("Time elapsed for \(title): \(timeElapsed) ms.")
    }
    
    private func transformData()
    {
        var groupedID : [ String:  [ String :  [Transaction] ] ] = [:]
//        var groupedCB : [ String:  [ Bool :  [Transaction] ] ] = [:]

        let IdOperation = (0 ..< listTransactions.count).map { (i) -> Transaction in
            return Transaction(year : listTransactions[i].sectionYear!, id: listTransactions[i].sectionIdentifier!, entityTransaction: listTransactions[i])
        }
        
        // Grouped year / month
        let groupedYear = Dictionary(grouping: IdOperation, by: { $0.year })
        for (key, value) in groupedYear {
            let valueID = Dictionary(grouping: value, by: {$0.id})
            groupedID[key] = valueID
        }
        
        
//        let groupedCB1 = Dictionary(grouping: IdOperation, by: { $0.id })
//        for (key, value) in groupedCB1 {
//            let valueID = Dictionary(grouping: value, by: {$0.cb})
//            groupedCB[key] = valueID
//        }
        
            // convert to struct - more fast and easy to sort
        var allGroupedYear : [ GroupedYearOperations ] = []
        
        for grouped in groupedID {
            let groupedYear = GroupedYearOperations(dictionary: grouped)
            allGroupedYear.append(groupedYear)
        }
        groupedSorted = allGroupedYear.sorted(by: {$0.year > $1.year })


        // convert to struct - more fast and easy to sort
//        var allGroupedYear : [ GroupedYearOperations ] = []
//
//        for grouped in groupedID {
//            let groupedYear = GroupedYearOperations(dictionary: grouped)
//            allGroupedYear.append(groupedYear)
//        }
//        groupedSorted = allGroupedYear.sorted(by: {$0.year > $1.year })
    }
    
    private func balanceCalculation()
    {
        let initCompte   = InitAccount.shared.getAllDatas()
        var balanceRealise = solde ? 0.0 : initCompte.realise
        var balancePrevu   = solde ? 0.0 : initCompte.prevu
        var balanceEngage  = solde ? 0.0 : initCompte.engage
        let initialBalance = balancePrevu + balanceEngage + balanceRealise
        let count        = listTransactions.count
        
        for index in stride(from: count - 1, to: -1, by: -1)
        {
            let statut = Int16(listTransactions[index].statut)

            let propertyEnum = Statut.TypeOfStatut(rawValue: statut)!
            switch propertyEnum
            {
            case .planifie:
                balancePrevu += listTransactions[index].amount
            case .engage:
                balanceEngage += self.listTransactions[index].amount
            case .realise:
                balanceRealise += self.listTransactions[index].amount
            }
            listTransactions[index].solde = index == count - 1 ? listTransactions[index].amount + initialBalance : listTransactions[index + 1].solde + listTransactions[index ].amount
        }
        
        self.soldeBanque.doubleValue = balanceRealise
        self.soldeReel.doubleValue   = balanceRealise + balanceEngage
        self.soldeFinal.doubleValue  = balanceRealise + balanceEngage + balancePrevu
        NotificationCenter.send(.updateBalance)
    }
    
    @IBAction func removeTransaction(_ sender: Any) {
        let selectedRows = outlineListView.selectedRowIndexes
        guard selectedRows.isEmpty == false else { return }
        
        for selectedRow in selectedRows {
            let item = outlineListView.item(atRow: selectedRow) as? Transaction
            if item!.entityTransaction.statut != 2 {
                
                NSAnimationContext.runAnimationGroup({context in
                    context.duration = 0.5
                    context.allowsImplicitAnimation = true
                    
                    ListTransactions.shared.remove(entity: (item?.entityTransaction)!)
                    self.view.layoutSubtreeIfNeeded()
                    
                }, completionHandler: nil)

            }
            else {
                let answer = dialogOKCancel(question: "Ok?", text: "Impossible de supprimer la transaction.\nLa transaction est verrouillée\nLe statut est 'Réalisé'")
                print (answer)
            }
        }
        
        self.getAllData()
        self.reloadData()
        
        self.resetChange()
    }
    
    @IBAction func compactTransaction(_ sender: Any) {
        let selectedRows = outlineListView.selectedRowIndexes
        guard selectedRows.isEmpty == false else { return }
        
        var listTransactions = [EntityTransactions]()
        
//        let context = mainObjectContext

//        var entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as? EntityTransactions

        for selectedRow in selectedRows {
            let item = outlineListView.item(atRow: selectedRow) as? Transaction
            listTransactions.append(item!.entityTransaction)
        }
        
//        for list in listTransactions {
//            ListTransactions.shared.remove(entity: list)
//        }
        
        self.getAllData()
        self.outlineListView.reloadData()
        self.reloadData()
        
        self.resetChange()
    }
}

extension ListTransactionsController: FilterDelegate {
    
    func applyFilter(_ fetchRequest: NSFetchRequest<EntityTransactions>) {
        
        let context = mainObjectContext
        
        do {
            listTransactions = try context!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        self.balanceCalculation()
        self.transformData()
        self.reloadData(true, false)
        self.resetChange()
    }
    
    func updateListeTransactions(_ liste: [EntityTransactions]) {
        
        listTransactions = liste
        
        self.balanceCalculation()
        self.transformData()
        self.reloadData(true, false)
    }
}

extension ListTransactionsController: OperationsDelegate {
    
    func updateAccount() {
        
        self.datePicker.dateValue = (currentAccount?.dateEcheancier!)!
        self.delegate?.resetOperation()
        self.getAllData()
        self.reloadData()
        
        self.resetChange()
    }
    
    func getAllData() {
        
        listTransactions = ListTransactions.shared.getAllDatas(ascending: false)
        self.balanceCalculation()
        self.transformData()
    }
    
    func reloadData(_ expand: Bool = false,_ auto: Bool = true) {
        
//        DispatchQueue.main.async {
            self.outlineListView.autosaveExpandedItems = false
            self.outlineListView.reloadData()
            self.outlineListView.autosaveExpandedItems = auto

            if expand == true {
                self.outlineListView.expandItem(nil, expandChildren: true)
                return
            }
            
            if self.outlineListView.autosaveExpandedItems,
               let autosaveName = self.outlineListView.autosaveName,
               let persistentObjects = UserDefaults.standard.array(forKey: "NSOutlineView Items \(autosaveName)"),
               let itemIds = persistentObjects as? [String] {
                let items = itemIds.sorted{ $0 < $1}
                items.forEach {
                    let item = self.outlineListView.dataSource?.outlineView?(self.outlineListView, itemForPersistentObject: $0)
                    if let item = item as? GroupedYearOperations {
                        self.outlineListView.expandItem(item)
                    }
                    if let item = item as? GroupedMonthOperations {
                        self.outlineListView.expandItem(item)
                    }
                }
            }
//        }
    }
    
    func expandAll() {
        if listTransactions.count > 0 {
            self.outlineListView.expandItem(nil, expandChildren: true)
        }
    }
}

