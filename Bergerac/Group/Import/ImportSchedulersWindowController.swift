    //
    //  ImportTransactionsWindowController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 23/10/2021.
    //

import AppKit


public protocol schedulersDelegate
{
        /// Called when a value has been selected inside the outline.
    func updateData()
}

final class ImportSchedulersWindowController: ImportWindowController {
    
    enum  TitlesScheduler : Int {
        case Ignore_Column = 0
        case Libellé
        case DateDeDébut
        case DateDeValeur
        case DateDeFin
        case Frequence
        case typeFrequence
        case Occurence
        case Rubrique
        case Catégorie
        case ModePaiement
        case Montant
    }
    
    public weak var schedulersDelegate: SchedulerViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let buttonOk = statusBarFormatViewController?.importButton
        buttonOk?.target = self
        buttonOk?.action = #selector(actionImportScheduler(_:))
    }
    
    @IBAction func actionImportScheduler(_ sender: NSButton) {
        
        let context = mainObjectContext
        
        let entityPreference = Preference.shared.getAllDatas()
        let formatDate = statusBarFormatViewController?.formatDate.stringValue
        
        let menuItem = statusBarFormatViewController?.popUpCompte.selectedItem
        let account = menuItem?.representedObject as! EntityAccount
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatDate
        
        let itemHeader = menuHeader.items
        
        for data in allData {
            
            let entitySchedule = NSEntityDescription.insertNewObject(forEntityName: "EntitySchedule", into: context!) as! EntitySchedule
            
            entitySchedule.account = account
            
            entitySchedule.dateCree = Date()
            entitySchedule.dateModifie = Date()
            
                // Libelle
            var headerColumn = itemHeader[TitlesScheduler.Libellé.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                let column = headerColumn[0].numCol
                if data.count > column {
                    entitySchedule.libelle = data[ column ]
                } else {
                    entitySchedule.libelle = ""
                }
            } else {
                entitySchedule.libelle = ""
            }
            
                // Date Début
            headerColumn = itemHeader[TitlesScheduler.DateDeDébut.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var dateDebut =  Date().noon
                let column = headerColumn[0].numCol
                let date = data[ column]
                if date == "" {
                    dateDebut = Date().noon
                } else {
                    dateDebut = dateFormatter.date(from: date)!.noon
                }
                entitySchedule.dateDebut = dateDebut
            } else {
                entitySchedule.dateDebut = Date().noon
            }
            
                // Date valeur
            headerColumn = itemHeader[TitlesScheduler.DateDeValeur.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var dateDeValeur =  Date().noon
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    dateDeValeur = Date().noon
                } else {
                    dateDeValeur = dateFormatter.date(from: dateStr)!.noon
                }
                entitySchedule.dateValeur = dateDeValeur
            } else {
                entitySchedule.dateValeur = Date().noon
            }
            
                // Date fin
            headerColumn = itemHeader[TitlesScheduler.DateDeFin.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                var dateFin =  Date().noon
                let column = headerColumn[0].numCol
                let dateStr = data[ column]
                if dateStr == "" {
                    dateFin = Date().noon
                } else {
                    dateFin = dateFormatter.date(from: dateStr)!.noon
                }
                entitySchedule.dateFin = dateFin
            } else {
                entitySchedule.dateFin = Date().noon
            }
            
            
                // Mode Paiement
            headerColumn = itemHeader[TitlesScheduler.ModePaiement.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                let label = data[ column]
                let entityModePaiement = PaymentMode.shared.find(name: label) ?? (entityPreference.paymentMode)!
                entitySchedule.paymentMode = entityModePaiement
                
            } else {
                entitySchedule.paymentMode = entityPreference.paymentMode
            }
            
                // Categorie
            headerColumn = itemHeader[TitlesScheduler.Catégorie.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                
                let colCat = headerColumn[0].numCol
                let labelCat = data[ colCat ]
                
                let entityCategory = Categories.shared.find(name: labelCat)
                entitySchedule.category = entityCategory ?? entityPreference.category
            } else {
                
                let category = entityPreference.category
                entitySchedule.category = category
            }
            
                // Montant
            headerColumn = itemHeader[TitlesScheduler.Montant.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                
                var amountStr = data[ column]
                if amountStr != "" {
                    amountStr = amountStr.replacingOccurrences(of: ",", with: ".")
                    amountStr = amountStr.replacingOccurrences(of: " ", with: "")
                        // https://stackoverflow.com/questions/5105053/iphone-uilabel-non-breaking-space
                    amountStr = amountStr.replacingOccurrences(of: "\u{00a0}", with: "")
                    let amount = Double(amountStr) ?? 0.0
                    entitySchedule.amount = amount
                }
            } else {
                entitySchedule.amount = 0.0
            }
            
                // Occurence
            headerColumn = itemHeader[TitlesScheduler.Occurence.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                let occurence = data[ column]
                entitySchedule.occurence = Int16(occurence) ?? 1
            } else {
                entitySchedule.occurence = 1
            }
            
                // Frequence
            headerColumn = itemHeader[TitlesScheduler.Frequence.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                let frequence = data[ column ]
                entitySchedule.frequence = Int16(frequence) ?? 12
            } else {
                entitySchedule.frequence = 12
            }
            
                // Type Frequence
            headerColumn = itemHeader[TitlesScheduler.typeFrequence.rawValue].representedObject as!  [HeaderColumnForMenu]
            if headerColumn.isEmpty == false {
                let column = headerColumn[0].numCol
                let typeFrequence = data[ column ]
                entitySchedule.typeFrequence = Int16(typeFrequence) ?? 2
            } else {
                entitySchedule.typeFrequence = 2
            }
            
            entitySchedule.uuid = UUID()
        }
        schedulersDelegate?.updateData()
        NotificationCenter.send(.updateBalance)
        
        self.close()
    }
}


