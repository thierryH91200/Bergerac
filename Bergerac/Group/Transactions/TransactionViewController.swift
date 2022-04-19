    //
    //  TransactionViewController.swift
    //  Bergerac
    //
    //  Created by thierry hentic on 07/03/2020.
    //  Copyright © 2020 thierry hentic. All rights reserved.
    //

import AppKit
import Charts
//import TFDate

// OperationController -> ListeOperationsController
public protocol OperationsDelegate {
    func getAllData()
    func reloadData(_ expand: Bool, _ auto: Bool)
}

final class TransactionViewController: NSViewController, NSTextFieldDelegate, NSControlTextEditingDelegate {
    
    public var delegate: OperationsDelegate?
    
    @IBOutlet weak var outlineViewSSOpe: NSOutlineView!
    @IBOutlet var menuLocal: NSMenu!
    
    @IBOutlet weak var addView: NSView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var gridView: NSGridView!
    
    @IBOutlet weak var buttonSave: NSButton!
    @IBOutlet weak var modeTransaction: NSButton!
    @IBOutlet weak var modeTransaction2: NSButton!
    @IBOutlet weak var column0: NSGridColumn!
    @IBOutlet weak var addBUtton: NSPopUpButton!
    @IBOutlet weak var removeButton: NSButton!
    
    @IBOutlet weak var popUpModePaiement: NSPopUpButton!
    @IBOutlet weak var popUpStatut: NSPopUpButton!
    @IBOutlet weak var popUpTransfert: NSPopUpButton!
    
    @IBOutlet weak var nameCompte: NSTextField!
    @IBOutlet weak var nameTitulaire: NSTextField!
    @IBOutlet weak var prenomTitulaire: NSTextField!
    
    @IBOutlet weak var textFieldMontant: NSTextField!
    @IBOutlet weak var textFieldReleveBancaire: NSTextField!
    
    @IBOutlet weak var dateOperation: NSDatePicker!
    @IBOutlet weak var datePointage: NSDatePicker!
    
    @IBOutlet weak var numCheque: NSTextField!
    @IBOutlet weak var numberCheck: NSTextField!
    
    @objc var date4: Date?
    @objc var date5: Date?

    public typealias root = EntitySousOperations
    
    var entityTransaction: EntityTransactions?
    var entityTransactions : [EntityTransactions] = []
    var entityTransactionsTransfert: EntityTransactions?
    var entityPreference: EntityPreference?
    var entityCompteTransfert: EntityAccount?
    var splitTransactions : [EntitySousOperations] = []
    
    var sousOperationModalWindowController: SousOperationModalWindowController!
    
    var setReleve        = Set<Double>()
    var setMontant       = Set<Double>()
    var setModePaiement  = Set<String>()
    var setStatut        = Set<Int16>()
    var setNumber        = Set<String>()
    var setTransfert     = Set<String>()
    var setCheck_In_Date = Set<Date>()
    var setDateOperation = Set<Date>()
    
    // edition = false => creation 1 transaction
    // edition = true => edition 1 to n transaction(s)
    var edition = false
    
    let key1 = Notification.Name.updateTransaction
    let key2 = Notification.Name.updateAccount
    
    var foregroundColor = NSColor.blue

    var dataRubricPie = [DataGraph]()
    var groupedBonds = [String: [DataGraph]]()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: key1)
        NotificationCenter.remove( self, name: key2)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive( self, selector: #selector(updateChangeCompte(_:)), name: key1)
        NotificationCenter.receive( self, selector: #selector(updateChangeCompte(_:)), name: key2)
        
        NotificationCenter.receive( self, selector: #selector(self.willShowPopup(_:)), name: .selectionDidChangePopUp )
        
        self.modeTransaction.bezelStyle = .texturedSquare
        self.modeTransaction.isBordered = false //Important
        self.modeTransaction.wantsLayer = true
        
        self.modeTransaction2.bezelStyle = .texturedSquare
        self.modeTransaction2.isBordered = false //Important
        self.modeTransaction2.wantsLayer = true
        
        self.textFieldMontant.isEnabled = false
        
        self.numCheque.isEnabled = true
        self.addView.isHidden = false
        
        numCheque.delegate = self
        textFieldReleveBancaire.delegate = self
        
        dateOperation.locale = Locale.current
        
        self.initChart()
    }
    
    @IBAction func popUpButtonUsed(_ sender: Any) {
        print("sender.indexOfSelectedItem")
    }
    
    @objc func willShowPopup(_ notification: Notification) {
        var bar = "willShowPopup"
        if let popUpButton = notification.object as? NSPopUpButton {
            if popUpButton == popUpStatut {
                bar = "popUpStatut"
                saveActions(false)
            }
        }
        print("bar = ",bar)
    }
    
    @objc func updateChangeCompte(_ notification: Notification) {
        
        self.resetOperation()
    }
    
    func controlTextDidEndEditing (_ notification: Notification) {
        
//        super.controlTextDidEndEditing(notification)
        var bar = ""
        if let textField = notification.object as? NSTextField {
            
            if textField == textFieldReleveBancaire {
                bar = "textFieldReleveBancaire"
                saveActions(false)
            }
            if textField == numCheque {
                bar = "numCheque"
                saveActions(false)
            }
        }
        
        if let popUpButton = notification.object as? NSPopUpButton {
            if popUpButton == popUpStatut {
                bar = "popUpStatut"
                saveActions(false)
            }
        }
        print("bar = ",bar)
    }
    
    private func initChart() {
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let attribut: [ NSAttributedString.Key: Any] =
            [  .font: NSFont(name: "HelveticaNeue-Light", size: 8.0)!,
               .foregroundColor: NSColor.gray,
               .paragraphStyle: paragraphStyle]
        
        let centerText = NSMutableAttributedString(string: Localizations.Transaction.operation)
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        self.pieChartView.centerAttributedText = centerText
        self.pieChartView.highlightPerTapEnabled = true
        self.pieChartView.drawSlicesUnderHoleEnabled = false
        self.pieChartView.holeRadiusPercent = 0.58
        self.pieChartView.transparentCircleRadiusPercent = 0.61
        self.pieChartView.drawCenterTextEnabled = true
        self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.drawEntryLabelsEnabled = false
        
        initializeLegend(self.pieChartView.legend)
        
        self.pieChartView.chartDescription?.enabled = false
        self.pieChartView.noDataText = Localizations.Chart.No_chart_Data_Available
        self.pieChartView.holeColor = .windowBackgroundColor
    }
    
    // MARK: Legend
    func initializeLegend(_ legend: Legend) {
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        
        legend.xEntrySpace = 7
        legend.yEntrySpace = 0
        legend.yOffset = 0
        
        legend.font = NSFont(name: "HelveticaNeue-Light", size: 8.0)!
        legend.textColor = NSColor.labelColor
    }
    
    // MARK: update Chart Data
    func updateChartData() {
        guard splitTransactions.isEmpty == false else {
            fatalError("subOperations.isEmpty")
        }
        self.dataRubricPie.removeAll()
        
        var nameRubric = ""
        var value = 0.0
        var color = NSColor.red
        for sousOperation in splitTransactions {
            
            value = sousOperation.amount
            nameRubric = (sousOperation.category?.rubric!.name)!
            color = (sousOperation.category?.rubric!.color) as! NSColor
            self.dataRubricPie.append(DataGraph(name: nameRubric, value: value, color: color))
        }
        self.groupedBonds = Dictionary(grouping: self.dataRubricPie) { (DataRubriquePie) -> String in
            return DataRubriquePie.name }
    }
    
    func setDataCount()
    {
        guard dataRubricPie.isEmpty == false else {
            pieChartView.data = nil
            pieChartView.data?.notifyDataChanged()
            pieChartView.notifyDataSetChanged()
            return }
        
        self.addView.isHidden = groupedBonds.isEmpty == false ? true : false
        
        // MARK: PieChartDataEntry
        var entries = [PieChartDataEntry]()
        var colors : [NSColor] = []
        
        for (key, values) in groupedBonds {
            
            var amount = 0.0
            for value in values {
                amount += value.value
            }
            
            let color = values[0].color
            entries.append(PieChartDataEntry(value: abs(amount), label: key))
            colors.append( color )
        }
        
        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Rubriques")
        dataSet.sliceSpace = 2.0
        
        dataSet.colors = colors
        dataSet.yValuePosition = .outsideSlice
        
        // MARK: PieChartData
        let data = PieChartData(dataSet: dataSet)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(8.0))!)
        data.setValueTextColor( .labelColor)
        self.pieChartView.data = data
        self.pieChartView.highlightValues(nil)
    }
    
    // edition = false => creation 1 operation
    // edition = true => edition 1 to n operation(s)
    func contextSaveEdition() {
        
        let context = mainObjectContext
        
        // creation = one operation
        if edition == false {
            
            // Create entityTransaction
            self.entityTransaction = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as? EntityTransactions
            self.entityTransaction?.dateCree = Date()
            self.entityTransaction?.uuid = UUID()
            self.entityTransaction?.account = currentAccount
            
            // Create entitySousOperation
            let setSousOperation = NSSet(array: splitTransactions)
            self.entityTransaction?.addToSousOperations(setSousOperation)
            self.entityTransactions.append(entityTransaction!)
        }
    }
    
    // MARK: - saveActions
    // edition = false => create  1 operation
    // edition = true  => edition 1 to n operation(s)
    @IBAction func saveActions(_ sender: Any) {
        
        var resetOp = true
        if let reset = sender as? Bool {
            resetOp = reset
            return
        }
        
        printTimeElapsedWhenRunningCode(title:"saveActions ") {
            self.contextSaveEdition()
            
            /// Multiple value
            for oneOperation in self.entityTransactions {
                
                let index = popUpStatut.indexOfSelectedItem
                let statut = oneOperation.statut
                if index == 3 && statut == 3 {
                    
                    let _ = dialogOKCancel(question: "Ok?", text: "Impossible de modifier la transaction.\nLa transaction est verrouillée\nLe statut est 'Réalisé'")
                    continue
                }
                oneOperation.dateModifie = Date()
                
                // DatePointage
                if (setCheck_In_Date.count > 1 && date5 != nil) || setCheck_In_Date.count == 1 {
                    oneOperation.datePointage  = datePointage.dateValue.noon
                }
                
                // DateOperation
                if (setDateOperation.count > 1 && date4 != nil) || setDateOperation.count == 1 {
                    oneOperation.dateOperation  = dateOperation.dateValue.noon
                }
                
                // Relevé bancaire
                if (setReleve.count > 1 && textFieldReleveBancaire.stringValue != "") || setReleve.count == 1 {
                    oneOperation.bankStatement = textFieldReleveBancaire.doubleValue
                }
                
                // ModePaiement
                if (setModePaiement.count > 1 && popUpModePaiement.indexOfSelectedItem != 0) || setModePaiement.count == 1 {
                    let menuItem = self.popUpModePaiement.selectedItem
                    let entityMode = menuItem?.representedObject as! EntityPaymentMode
                    oneOperation.paymentMode = entityMode
                }
                
                // Statut
                if (setStatut.count > 1 && popUpStatut.indexOfSelectedItem != 0) || setStatut.count == 1 {
                    let item = self.popUpStatut.selectedItem
                    let statut = Int16(item?.tag ?? 0)
                    oneOperation.statut = statut
                }
                // checkNumber
                if (setNumber.count > 1 && numCheque.stringValue != "") || setNumber.count == 1 {
                    let item = self.numCheque.stringValue
                    oneOperation.checkNumber = item
                }
                
                // Operation Link
                let transfert = popUpTransfert.indexOfSelectedItem
                if (setTransfert.isEmpty == false && transfert > 1)  {
                    createOperationLiee(oneOperation: oneOperation)
                }
                else {
                    oneOperation.operationLiee = nil
                }
            }
            
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            
            self.delegate?.getAllData()
            self.delegate?.reloadData(false, true)
            
            NotificationCenter.send(.updateBalance)
            if resetOp == true {
                self.resetOperation()
            }
        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func getTodoItems() {
        if let context = mainObjectContext
        {
            do {
                entityTransactions = try context.fetch(EntityTransactions.fetchRequest())
                print("get: \(entityTransactions)")
            } catch {
            }
            self.delegate?.getAllData()
            self.delegate?.reloadData(true, true)
        }
    }
    
    func createOperationLiee(oneOperation: EntityTransactions ) {
        
        let context = mainObjectContext
        if oneOperation.operationLiee == nil {
            
            self.entityTransactionsTransfert = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as? EntityTransactions
            self.entityTransactionsTransfert?.operationLiee = oneOperation
            oneOperation.operationLiee = entityTransactionsTransfert
            
        } else {
            self.entityTransactionsTransfert = oneOperation.operationLiee
        }
        
        let menuItem = popUpTransfert.selectedItem
        let compteTransfert = menuItem?.representedObject as! EntityAccount
        
        entityTransactionsTransfert?.account       = compteTransfert
        
        entityTransactionsTransfert?.dateModifie   = oneOperation.dateModifie
        entityTransactionsTransfert?.dateCree      = oneOperation.dateCree
        
            // Date operation
        entityTransactionsTransfert?.dateOperation = oneOperation.dateOperation
        
            // Date Pointage
        entityTransactionsTransfert?.datePointage  = oneOperation.datePointage
        
            // le modePaiement existe t il ??
        let name               = oneOperation.paymentMode?.name
        let color              = oneOperation.paymentMode?.color
        let uuid               = oneOperation.paymentMode?.uuid
        let entityModePaiement = PaymentMode.shared.findOrCreate(account : compteTransfert, name : name!, color : color as! NSColor, uuid : uuid!)
        entityTransactionsTransfert?.paymentMode  = entityModePaiement
        
        entityTransactionsTransfert?.statut        = oneOperation.statut
        entityTransactionsTransfert?.bankStatement = oneOperation.bankStatement
        
        let entityPreference = Preference.shared.getAllDatas()
        
        let setSout   = oneOperation.sousOperations
        splitTransactions = setSout?.allObjects as! [EntitySousOperations]
        
        entityTransactionsTransfert?.sousOperations = nil
        
        for sousOperation in splitTransactions {
            
            let entitySousOperationsTransfert = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context!) as? EntitySousOperations
            
                // la rubrique existe t elle ??
            let labelCat = (sousOperation.category?.name)!
            let entityCategory = Categories.shared.find(name: labelCat)
            entitySousOperationsTransfert!.category = entityCategory ?? entityPreference.category
            
                // Amount
            entitySousOperationsTransfert!.amount       = -sousOperation.amount
            
                // Libelle
            entitySousOperationsTransfert!.libelle       = sousOperation.libelle
            
            entityTransactionsTransfert?.addToSousOperations(entitySousOperationsTransfert!)
        }
        entityTransactionsTransfert?.uuid          = UUID()
    }
}

extension TransactionViewController: NSMenuDelegate {
    // MARK: - Enable Menu item
    func menuWillOpen( _ menu: NSMenu) {
        for menuItem in menu.items
        {
            let tag = menuItem.tag
            if tag == 1  {
                menuItem.isEnabled = outlineViewSSOpe.selectedRow != -1 ? true : false
            }
            if tag == 2 {
                menuItem.isEnabled = splitTransactions.count > 1 && outlineViewSSOpe.selectedRow != -1 ? true : false
            }
        }
    }
}

extension TransactionViewController: NSWindowDelegate, NSAlertDelegate {
    
    func window(_ window: NSWindow, willPositionSheet sheet: NSWindow, using rect: NSRect) -> NSRect {
        
        if sheet == self.sousOperationModalWindowController?.window ||
            sheet == self.outlineViewSSOpe.window
        {
            var rectToReturn = self.outlineViewSSOpe.frame
            let rectWin = window.frame
            rectToReturn.size = CGSize(width: rectToReturn.width, height: 0)
            rectToReturn.origin.x = rectWin.width - rectToReturn.width
            rectToReturn.origin.y = rect.origin.y //- rectAddView.height
            return rectToReturn
        } else {
            return rect
        }
    }
    
}
