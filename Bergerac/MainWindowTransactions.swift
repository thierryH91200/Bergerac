    //
    //  MainWindowTransactions.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 23/10/2021.
    //

import AppKit

extension MainWindowController {
    
    
        // MARK: - Import Transactions Detaillee
    @IBAction func ImportTransactionsDetaillee(_ sender: Any) {
        
        var titles = [String]()

        let listTransactionsController = viewController.controller()
        _ = listTransactionsController.view
        let tableCols = listTransactionsController.outlineListView.tableColumns
        for tablecol in tableCols {
            titles.append(tablecol.title)
        }
        titles.remove(at: titles.count - 1)
        titles.remove(at: titles.count - 1)
        titles.remove(at: titles.count - 1)
        titles.remove(at: titles.count - 1)

        importWindowController = ImportTransactionsWindowController()
        importWindowController?.delegate = viewController.listTransactionsController
        importWindowController?.titles = titles
        importWindowController?.showWindow(nil)
    }
    
        // MARK: - Import Transactions Simplifiee
    @IBAction func ImportTransactionsSimplifiee(_ sender: Any) {
        
        let context = mainObjectContext
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["csv", "txt"]
        
        panel.beginSheetModal(for: self.window!) { (result) in
            var content = ""
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                
                let url = panel.urls.first!
                do {
                    content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                } catch {
                    print(error)
                }
                
                let entityPreference = Preference.shared.getAllDatas()
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = .short
                let now = dateformatter.string(from: Date().noon)
                
                let result = content.replacingOccurrences(of: ",", with: ",", options: String.CompareOptions.literal, range: nil)
                let csv = CSwiftV(with: result, separator: ";")
                
                let allKey = csv.keyedRows
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                
                if let keys = allKey
                {
                    let dateTransaction = Localizations.SimplifiedImport.Menu.dateTransaction
                    let datePointage    = Localizations.SimplifiedImport.Menu.datePointage
                    let mode            = Localizations.SimplifiedImport.Menu.paymentMethod
                    let statut          = Localizations.SimplifiedImport.Menu.statut
                    let bankStatement   = Localizations.SimplifiedImport.Menu.bankStatement
                    
                        // SousOperations
                    let keyLibelle   = Localizations.SimplifiedImport.Menu.comment
                    let keyCategorie = Localizations.SimplifiedImport.Menu.category
                    let keyAmount    = Localizations.SimplifiedImport.Menu.amount
                    
                    for key in keys
                    {
                        let amount = key[keyAmount] ?? "0.0"
                        
                        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as! EntityTransactions
                        
                        entity.account = currentAccount
                        
                        entity.dateCree      = Date()
                        entity.dateModifie   = Date()
                        entity.dateOperation = dateFormatter.date(from : key[dateTransaction] ?? now)
                        entity.datePointage  = dateFormatter.date(from  : key[datePointage] ?? now)
                        
                        let labelMode          = key[mode] ?? (entityPreference.paymentMode?.name)!
                        let entityModePaiement = PaymentMode.shared.find(name : labelMode) ?? (entityPreference.paymentMode)!
                        entity.paymentMode     = entityModePaiement
                        
                        let bankState        = key[bankStatement] ?? "0.0"
                        entity.bankStatement = Double(bankState)!
                        
                        let label     = Statut.TypeOfStatut(rawValue         : entityPreference.statut)!.label
                        let numStatut = Statut.shared.findStatut( statut : key[statut] ?? label)
                        entity.statut = numStatut
                        
                            // EntitySplitTransactions
                        let entitySplitTransaction = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context!) as! EntitySousOperations

                        let sign = -1
                        if amount != "" {
                            
                            let amount = amount.removeFormatAmount()
                            entitySplitTransaction.amount =  amount * Double(sign)
                        }
                        else {
                            entitySplitTransaction.amount = 0.0
                        }
                        
                        entitySplitTransaction.libelle = key[keyLibelle] ?? keyLibelle
                        
                        let labelCat = key[keyCategorie] ?? (entityPreference.category?.name)!
                        let entityCategory = Categories.shared.find(name: labelCat)
                        entitySplitTransaction.category = entityCategory
                        
                        entity.addToSousOperations(entitySplitTransaction)
                        
                        entity.uuid = UUID()
                        entity.account?.name = key["compte"] ?? entityPreference.account?.name
                    }
                    self.viewController.listTransactionsController?.getAllData()
                    self.viewController.listTransactionsController?.reloadData()
                }
            }
        }
    }
    
        // MARK: - Export Transactions Simplifiee
    @IBAction func ExportTransactions(_ sender: Any) {
        
        accessoryViewController = TTFormatViewController(nibName: NSNib.Name( "TTFormatViewControllerAccessory"), bundle: nil)
        
        let csvConfig =  accessoryViewController?.config
        
        let savePanel = NSSavePanel()
        savePanel.accessoryView = accessoryViewController?.view
        accessoryViewController?.config.isFirstRowAsHeader = (csvConfig?.isFirstRowAsHeader)!
        savePanel.allowedFileTypes = ["csv"]
        let name = defaultDraftName("Transaction_")
        savePanel.nameFieldStringValue = name + ".csv" // <-- user editable prompt
        
        savePanel.begin { (result) -> Void in
            
            let encoding = self.accessoryViewController?.config.encoding
            if result == NSApplication.ModalResponse.OK {
                let filename = savePanel.url
                let exportString = self.createExportTransaction()
                
                do {
                    try exportString.write(to: filename!, atomically: true, encoding: encoding!)
                } catch {
                        // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }
    }
    
    func createExportTransaction() -> String {
        
        let config = accessoryViewController?.config
        delimiter = String((config?.delimiter)!)
        quote = (config?.quoteCharacter)!
        
        let listeTransactions = ListTransactions.shared.getAllDatas()
        
        var account = ""
        var data = ""
        
        let listTransactionsController = ListTransactionsController()
        _ = listTransactionsController.view
        let tablecols = listTransactionsController.outlineListView.tableColumns
        var titles = [String]()
        for tablecol in tablecols {
            titles.append(tablecol.title)
        }
        print(titles)
        export = ""
        for title in titles {
            export = quote + title + "\(quote)\(delimiter)"
        }
        export = "\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        for listeTransaction in listeTransactions {
            
            let spiltTransactions = listeTransaction.sousOperations!.allObjects as! [EntitySousOperations]
            for spiltTransaction in spiltTransactions {
                
                data  = dateFormatter.string(from: listeTransaction.datePointage!)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data = dateFormatter.string(from: listeTransaction.dateOperation!)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data       = spiltTransaction.libelle!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data        = String(listeTransaction.statut)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data      = (spiltTransaction.category?.rubric?.name)!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data     = (spiltTransaction.category?.name)!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data  = (listeTransaction.paymentMode?.name!)!
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data  = String(listeTransaction.bankStatement)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                data       = String(spiltTransaction.amount)
                export = "\(quote)\(data)\(quote)\(delimiter)"
                
                account        = (listeTransaction.account?.name)!
                export = "\(quote)\(account)\(quote)\n"
            }
        }
        return export
    }
}
