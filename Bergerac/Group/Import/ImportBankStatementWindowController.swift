    //
    //  ImportTransactionsWindowController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 23/10/2021.
    //

import AppKit


final class ImportBankStatementWindowController: ImportWindowController {
    
    enum  TitlesBank : Int {
        case Ignore_Column = 0
        case number
        case dateDebut
        case soldeDebut
        case dateInter
        case soldeInter
        case dateFin
        case soldeFin
        case dateCB
        case soldeCB
    }
    
    public var delegate: OperationsDelegate?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let buttonOk = statusBarFormatViewController?.importButton
        buttonOk?.target = self
        buttonOk?.action = #selector(actionImportBank(_:))
        
        self.window?.title = "Relevé bancaire"
    }
    
    @IBAction func actionImportBank(_ sender: NSButton) {
        
        let context = mainObjectContext
        
        let formatDate = statusBarFormatViewController?.formatDate.stringValue
        
        let menuItem = statusBarFormatViewController?.popUpCompte.selectedItem
        let account = menuItem?.representedObject as! EntityAccount
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatDate
        
        let itemHeader = menuHeader.items
        
        for data in allData {
            
            let entityBankStatement = NSEntityDescription.insertNewObject(forEntityName: "EntityBankStatement", into: context!) as! EntityBankStatement
            
            entityBankStatement.account = account
            
                // number
            var headerColumn = itemHeader[TitlesBank.number.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                entityBankStatement.number = Double(label) ?? 0.0
                
            } else {
                entityBankStatement.number = 0.0
            }
            
                // Date debut
            headerColumn = itemHeader[TitlesBank.dateDebut.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                var dateDebut =  Date().noon
                
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    dateDebut = Date().noon
                } else {
                    dateDebut = dateFormatter.date(from: dateStr)!.noon
                }
                entityBankStatement.dateDebut = dateDebut
            } else {
                entityBankStatement.dateDebut = Date().noon
            }
            
                // soldeDebut
            headerColumn = itemHeader[TitlesBank.soldeDebut.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let soldeDebut = Double(data[ column])
                entityBankStatement.soldeDebut = soldeDebut ?? 0.0
                
            } else {
                entityBankStatement.soldeDebut = 0.0
            }

            
                // dateInter
            headerColumn = itemHeader[TitlesBank.dateInter.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                var dateInter =  Date().noon
                
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    dateInter = Date().noon
                } else {
                    dateInter = dateFormatter.date(from: dateStr)!.noon
                }
                entityBankStatement.dateInter = dateInter
            } else {
                entityBankStatement.dateInter = Date().noon
            }
            
                // soldeInter
            headerColumn = itemHeader[TitlesBank.soldeInter.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                entityBankStatement.soldeInter = Double(label) ?? 0.0
                
            } else {
                entityBankStatement.soldeInter = 0.0
            }

            
                // Date Fin
            headerColumn = itemHeader[TitlesBank.dateFin.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                var dateFin =  Date().noon
                
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    dateFin = Date().noon
                } else {
                    dateFin = dateFormatter.date(from: dateStr)!.noon
                }
                entityBankStatement.dateFin = dateFin
            } else {
                entityBankStatement.dateFin = Date().noon
            }
            
                // soldeFin
            headerColumn = itemHeader[TitlesBank.soldeFin.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                entityBankStatement.soldeFin = Double(label) ?? 0.0
                
            } else {
                entityBankStatement.soldeFin = 0.0
            }
            
                // Date CB
            headerColumn = itemHeader[TitlesBank.dateCB.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                var dateCB =  Date().noon
                
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    dateCB = Date().noon
                } else {
                    dateCB = dateFormatter.date(from: dateStr)!.noon
                }
                entityBankStatement.dateCB = dateCB
            } else {
                entityBankStatement.dateCB = Date().noon
            }
            
                // solde CB
            headerColumn = itemHeader[TitlesBank.soldeCB.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                entityBankStatement.soldeCB = Double(label) ?? 0.0
                
            } else {
                entityBankStatement.soldeCB = 0.0
            }

            entityBankStatement.uuid = UUID()
        }

        delegate?.getAllData()
        delegate?.reloadData(true, false)
        NotificationCenter.send(.updateBalance)
        
        self.close()
    }
}


