    //
    //  MainWindowBankStatement.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 23/10/2021.
    //

import AppKit
import Quartz


extension MainWindowController {
    
        // MARK: - Import Releve Bancaire Detaillee
    @IBAction func ImportBankStatementDetaillee(_ sender: Any) {
        
        var titles = [String]()

        let listBankStatementController = ListBankStatementController()
        _ = listBankStatementController.view
        let tableCols = listBankStatementController.tableBankStatement.tableColumns
        for tablecol in tableCols {
            titles.append(tablecol.title)
        }

        importBankStatementWindowController = ImportBankStatementWindowController()
        importBankStatementWindowController?.titles = titles
        importBankStatementWindowController?.showWindow(nil)
    }
    
        // MARK: - Import Releve Bancaire Simplifiee
    @IBAction func ImportBankStatementSimplified(_ sender: Any) {
        
        let context = mainObjectContext
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        let allowedContentTypes: [UTType] = [.commaSeparatedText, .text]
        panel.allowedContentTypes = allowedContentTypes
        
        panel.beginSheetModal(for: self.window!) { (result) in
            var content = ""
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                
                let url = panel.urls.first!
                do {
                    content = try String(contentsOf: url, encoding: String.Encoding.macOSRoman)
                } catch {
                    print(error)
                }
                
//                let entityPreference = Preference.shared.getAllDatas()
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = .short
                let now = dateformatter.string(from: Date().noon)
                
                let result = content.replacingOccurrences(of: ",", with: ",", options: String.CompareOptions.literal, range: nil)
                let csv = CSwiftV(with: result, separator: ";")
                
                let allKey = csv.keyedRows
                let header = csv.headers
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                
                if let keys = allKey
                {
                    let ref = header[0]
                    
                    let dateDebut = header[1]
                    let dateInter = header[2]
                    let dateFin = header[3]
                    let dateCB = header[4]
                    
                    let soldeDebut = header[5]
                    let soldeInter = header[6]
                    let soldeFin = header[7]
                    let soldeCB = header[8]
                    
                    for key in keys
                    {
                        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntityBankStatement", into: context!) as! EntityBankStatement
                        
                        entity.number = Double( key[ref] ?? "0.0" )!
                        
                        entity.dateDebut = dateFormatter.date(from: key[dateDebut] ?? now)
                        entity.dateFin = dateFormatter.date(from: key[dateFin] ?? now)
                        entity.dateInter = dateFormatter.date(from: key[dateInter] ?? now)
                        entity.dateCB = dateFormatter.date(from: key[dateCB] ?? now)
                        
                        entity.soldeDebut = Double( key[ soldeDebut ] ?? "0.0")!
                        entity.soldeInter = Double( key[soldeInter] ?? "0.0")!
                        entity.soldeFin   = Double( key[soldeFin] ?? "0.0")!
                        entity.soldeCB    = Double( key[soldeCB] ?? "0.0")!

                        entity.uuid = UUID()
                        entity.account = currentAccount
                    }
                        //                    self.viewController.listTransactionsController?.getAllData()
                        //                    self.viewController.listTransactionsController?.reloadData()
                }
            }
        }
        
    }
    
        // MARK: - Export Releve Bancaire
    @IBAction func ExportBankStatement(_ sender: Any) {
        
        accessoryViewController = TTFormatViewController(nibName: NSNib.Name( "TTFormatViewControllerAccessory"), bundle: nil)
        
        let csvConfig =  accessoryViewController?.config
        
        let savePanel = NSSavePanel()
        savePanel.accessoryView = accessoryViewController?.view
        accessoryViewController?.config.isFirstRowAsHeader = (csvConfig?.isFirstRowAsHeader)!
        
        let allowedContentTypes: [UTType] = [.commaSeparatedText, .text]
        savePanel.allowedContentTypes = allowedContentTypes
        let name = defaultDraftName("BankStatements_")
        savePanel.nameFieldStringValue = name + ".csv" // <-- user editable prompt
        
        savePanel.begin { (result) -> Void in
            
            let encoding = self.accessoryViewController?.config.encoding
            if result == NSApplication.ModalResponse.OK {
                let filename = savePanel.url
                let exportString = self.createExportBankStatements()
                
                do {
                    try exportString.write(to: filename!, atomically: true, encoding: encoding!)
                } catch {
                        // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }
    }
    
        // MARK: - Export Releve Bancaire
    func createExportBankStatements() -> String {
        
        var titles = [String]()
        var data = ""
        export = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let config = accessoryViewController?.config
        delimiter = String((config?.delimiter)!)
        quote = (config?.quoteCharacter)!
        
        let bankStatements = BankStatement.shared.getAllDatas()
        
        let listBankStatementController = ListBankStatementController()
        _ = listBankStatementController.view
        let tableCols = listBankStatementController.tableBankStatement.tableColumns
        for tablecol in tableCols {
            titles.append(tablecol.title)
        }
        
        for title in titles {
            export = quote + title + "\(quote)\(delimiter)"
        }
        export = quote + "reserve" + "\(quote)\n"
        
        print(export)
        
        for bankStatement in bankStatements {
            data  = String(bankStatement.number)
            export = "\(quote)\(data)\(quote)\(delimiter)"
            
            data  = dateFormatter.string(from: bankStatement.dateDebut!)
            export = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(bankStatement.soldeDebut)
            export  = "\(quote)\(data)\(quote)\(delimiter)"

            data  = dateFormatter.string(from: bankStatement.dateInter!)
            export = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(bankStatement.soldeInter)
            export  = "\(quote)\(data)\(quote)\(delimiter)"

            data    = dateFormatter.string(from : bankStatement.dateFin!)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(bankStatement.soldeFin)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = dateFormatter.string(from : bankStatement.dateCB!)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(bankStatement.soldeCB)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = (bankStatement.uuid?.uuidString)!
            export  = "\(quote)\(data)\(quote)\n"
            
        }
        return export
    }
    
}
