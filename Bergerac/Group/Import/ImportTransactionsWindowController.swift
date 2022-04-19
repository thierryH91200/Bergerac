    //
    //  ImportTransactionsWindowController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 23/10/2021.
    //

import AppKit


final class ImportTransactionsWindowController: ImportWindowController {
    
    enum  TitlesTrans : Int {
        case Ignore_Column = 0
        case DatePointage
        case DateTransaction
        case Libellé
        case Rubrique
        case Catégorie
        case ModePaiement
        case RelevéBancaire
        case NuméroCheque
        case Statut
        case Montant
    }

    public var delegate: OperationsDelegate?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
        
    func importSousOperation(data: [String ] ) -> EntitySousOperations {
        
        let context = mainObjectContext
        let itemHeader = menuHeader.items
        
        let entityPreference = Preference.shared.getAllDatas()
        
        let reverse = statusBarFormatViewController?.reverseSignAmountCheckBbox.state
        let sign = reverse == .on ? -1 : 1
        
            // Creation entitySousOperation
        let entitySplitTransaction = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context!) as! EntitySousOperations
        
            // Libelle
        var headerColumn = itemHeader[TitlesTrans.Libellé.rawValue].representedObject as!  [HeaderColumnForMenu]
        if headerColumn.isEmpty == false {
            
            let column = headerColumn[0].numCol
            if  data.count > column {
                entitySplitTransaction.libelle = data[ column ]
            } else {
                entitySplitTransaction.libelle = ""
            }
        } else {
            entitySplitTransaction.libelle = ""
        }
        
            /// Montant
        headerColumn = itemHeader[TitlesTrans.Montant.rawValue].representedObject as!  [HeaderColumnForMenu]
        if headerColumn.isEmpty == false {
            
            let colMontant = headerColumn[0].numCol
            let amountStr = data[ colMontant]
            if amountStr != "" {
                
                let amount = amountStr.removeFormatAmount()
                entitySplitTransaction.amount =  amount * Double(sign)
            }
        } else {
            entitySplitTransaction.amount = 0.0
        }
        
            // Rubric
            //            headerColumn = itemHeader[8].representedObject as!  [HeaderColumnForMenu]
            //            if headerColumn.isEmpty == false {
            //
            //                let colRub = headerColumn[0].numCol
            //                let labelRub = data[ colRub ]
            //
            //                let entityRubric = Rubric.shared.find(name: labelRub)
            //                entitySousOperation.category?.rubric = entityRubric ?? entityPreference.category?.rubric
            //            } else {
            //
            //                let rubric = entityPreference.category?.rubric
            //                entitySousOperation.category?.rubric = rubric
            //            }
        
        // Categorie
        headerColumn = itemHeader[TitlesTrans.Catégorie.rawValue].representedObject as!  [HeaderColumnForMenu]
        if headerColumn.isEmpty == false {
            
            let colCat = headerColumn[0].numCol
            let labelCat = data[ colCat ]
            
            let entityCategory = Categories.shared.find(name: labelCat)
            entitySplitTransaction.category = entityCategory ?? entityPreference.category
        } else {
            
            let category = entityPreference.category
            entitySplitTransaction.category = category
        }
        return entitySplitTransaction
    }
    
    @IBAction func actionImport(_ sender: NSButton) {
        
        let context = mainObjectContext
        
        let entityPreference = Preference.shared.getAllDatas()
        let formatDate = statusBarFormatViewController?.formatDate.stringValue
        
        let menuItem = statusBarFormatViewController?.popUpCompte.selectedItem
        let account = menuItem?.representedObject as! EntityAccount
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatDate
        
        let itemHeader = menuHeader.items
        
        for data in allData {
            
            var isEmpty = true
            for datas in data where datas != "" {
                isEmpty = false
                continue
            }
            guard isEmpty == false else { continue }
                        
            let entityOperation = NSEntityDescription.insertNewObject(forEntityName: "EntityTransactions", into: context!) as! EntityTransactions
            
            entityOperation.account = account
            
            entityOperation.dateCree = Date()
            entityOperation.dateModifie = Date()
            
                // Date transaction
            var headerColumn = itemHeader[TitlesTrans.DateTransaction.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var dateTransaction =  Date().noon
                let column = headerColumn[0].numCol
                let date = data[ column]
                if date == "" {
                    dateTransaction = Date().noon
                } else {
                    dateTransaction = dateFormatter.date(from: date)!.noon
                }
                entityOperation.dateOperation = dateTransaction
            } else {
                entityOperation.dateOperation = Date().noon
            }
            
                // Date Pointage
            headerColumn = itemHeader[TitlesTrans.DatePointage.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var datePointage =  Date().noon
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    datePointage = entityOperation.dateOperation!
                } else {
                    datePointage = dateFormatter.date(from: dateStr)!.noon
                }
                entityOperation.datePointage = datePointage
            } else {
                entityOperation.datePointage = entityOperation.dateOperation
            }
            
                // Statut
            headerColumn = itemHeader[TitlesTrans.Statut.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                let statut = data[ column]
                entityOperation.statut = Int16(statut) ?? 1
            } else {
                entityOperation.statut = entityPreference.statut
            }
            
                // Mode Paiement
            headerColumn = itemHeader[TitlesTrans.ModePaiement.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                let entityModePaiement = PaymentMode.shared.find(name: label) ?? (entityPreference.paymentMode)!
                entityOperation.paymentMode = entityModePaiement
                
            } else {
                entityOperation.paymentMode = entityPreference.paymentMode
            }
            
                /// Bank Statement
            headerColumn = itemHeader[TitlesTrans.RelevéBancaire.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                entityOperation.bankStatement = Double(label) ?? 0.0
                
            } else {
                entityOperation.bankStatement = 0.0
            }
            
            let entitySousOperation = importSousOperation(data: data )
            
            entityOperation.addToSousOperations(entitySousOperation)
            entityOperation.uuid = UUID()
        }
        
        delegate?.getAllData()
        delegate?.reloadData(true, false)
        NotificationCenter.send(.updateBalance)
        
        self.close()
    }
}



