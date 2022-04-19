    //
    //  MainWindowSchedulers.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 23/10/2021.
    //

import AppKit

extension MainWindowController {
    
        // MARK: - Import Schedulers Detaillee
    @IBAction func ImportSchedulersDetaillee(_ sender: Any) {
        
        var titles = [String]()

        let schedulerViewController = SchedulerViewController()
        _ = schedulerViewController.view
        let tableCols = schedulerViewController.tableViewScheduler.tableColumns
        for tablecol in tableCols {
            titles.append(tablecol.title)
        }
        titles.remove(at: titles.count - 1)
        titles.remove(at: titles.count - 1)
        titles.remove(at: titles.count - 1)
        titles.remove(at: titles.count - 1)
        
        importSchedulersWindowController = ImportSchedulersWindowController()
        importSchedulersWindowController?.schedulersDelegate = viewController.schedulerViewController
        importSchedulersWindowController?.titles = titles
        importSchedulersWindowController?.showWindow(nil)
    }
    
        // MARK: - Import Scheduler Simplifiee
    @IBAction func ImportSchedulersSimplified(_ sender: Any) {
        
        let context = mainObjectContext
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["csv", "txt"]
        
        panel.beginSheetModal(for: self.window!) { (result) in
            var content = ""
            if result == NSApplication.ModalResponse.OK {
                
                let url = panel.urls.first!
                do {
                    content = try String(contentsOf: url, encoding: String.Encoding.macOSRoman)
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
                let header = csv.headers
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                
                if let keys = allKey
                {
                    let libelle = header[0]
                    let dateDebut = header[1]
                    let dateValeur = header[2]
                    let dateFin = header[3]
                    
                    let frequence = header[4]
                    let occurence = header[5]
                    let categorie = header[7]
                    let mode = header[8]
                    let amount = header[9]
                    
                    for key in keys
                    {
                        let entity = NSEntityDescription.insertNewObject(forEntityName: "EntitySchedule", into: context!) as! EntitySchedule
                        
                        entity.dateCree = dateFormatter.date(from: now)
                        entity.dateModifie = dateFormatter.date(from: now)
                        
                        entity.dateDebut = dateFormatter.date(from: key[dateDebut] ?? now)
                        entity.dateFin = dateFormatter.date(from: key[dateFin] ?? now)
                        entity.dateValeur = dateFormatter.date(from: key[dateValeur] ?? now)
                        
                        entity.libelle = key[libelle]
                        entity.frequence = Int16(exactly: Int( key[frequence]!) ?? 1)!
                        entity.typeFrequence = Int16(exactly: Int( key[frequence]!) ?? 2)!
                        entity.occurence = Int16(exactly: Int( key[occurence]!) ?? 0)!
                        
                        let labelMode = key[mode] ?? (entityPreference.paymentMode?.name)!
                        let entityModePaiement = PaymentMode.shared.find(name: labelMode) ?? (entityPreference.paymentMode)!
                        entity.paymentMode = entityModePaiement
                        
                        let labelCat = key[categorie] ?? (entityPreference.category?.name)!
                        let entityCategory = Categories.shared.find(name: labelCat)
                        entity.category = entityCategory
                        
                        entity.amount = Double(key[amount]!) ?? 0.0
                        
                        entity.uuid = UUID()
                        entity.account = currentAccount
                    }
        //     self.viewController.listTransactionsController?.getAllData()
        //     self.viewController.listTransactionsController?.reloadData()
                }
            }
        }
        
        
    }
    
        // MARK: - Export Scheduler
    @IBAction func ExportSchedulers(_ sender: Any) {
        
        accessoryViewController = TTFormatViewController(nibName: NSNib.Name( "TTFormatViewControllerAccessory"), bundle: nil)
        
        let csvConfig =  accessoryViewController?.config
        
        let savePanel = NSSavePanel()
        savePanel.accessoryView = accessoryViewController?.view
        accessoryViewController?.config.isFirstRowAsHeader = (csvConfig?.isFirstRowAsHeader)!
        savePanel.allowedFileTypes = ["csv"]
        let name = defaultDraftName("Scheduler_")
        savePanel.nameFieldStringValue = name + ".csv" // <-- user editable prompt
        
        savePanel.begin { (result) -> Void in
            
            let encoding = self.accessoryViewController?.config.encoding
            if result == NSApplication.ModalResponse.OK {
                let filename = savePanel.url
                let exportString = self.createExportScheduler()
                
                do {
                    try exportString.write(to: filename!, atomically: true, encoding: encoding!)
                } catch {
                        // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }
    }
    
    func createExportScheduler() -> String {
        
        var titles = [String]()
        var account = ""
        var data = ""
        export = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let config = accessoryViewController?.config
        delimiter = String((config?.delimiter)!)
        quote = (config?.quoteCharacter)!
        
        let schedulers = Scheduler.shared.getAllDatas()
        
        let schedulerViewController = SchedulerViewController()
        _ = schedulerViewController.view
        let tableCols = schedulerViewController.tableViewScheduler.tableColumns
        for tablecol in tableCols {
            titles.append(tablecol.title)
        }
        
        for title in titles {
            export = quote + title + "\(quote)\(delimiter)"
        }
        export = quote + "nextOccurence" + "\(quote)\(delimiter)"
        export = quote + "typeFrequence" + "\(quote)\n"
        
        print(export)
        
        for scheduler in schedulers {
            data  = scheduler.libelle!
            export = "\(quote)\(data)\(quote)\(delimiter)"
            
            data  = dateFormatter.string(from: scheduler.dateDebut!)
            export = "\(quote)\(data)\(quote)\(delimiter)"
            
            data  = dateFormatter.string(from: scheduler.dateValeur!)
            export = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = dateFormatter.string(from : scheduler.dateFin!)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(scheduler.frequence)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(scheduler.occurence)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = (scheduler.category?.rubric?.name!)!
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = (scheduler.category?.name!)!
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = (scheduler.paymentMode?.name)!
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(scheduler.amount)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            account = (scheduler.account?.initAccount?.codeAccount)!
            export  = "\(quote)\(account)\(quote)\(delimiter)"
            
            account = (scheduler.account?.name)!
            export  = "\(quote)\(account)\(quote)\(delimiter)"
            
            account = (scheduler.account?.identity?.name)!
            export  = "\(quote)\(account)\(quote)\(delimiter)"
            
            account = (scheduler.account?.identity?.surName)!
            export  = "\(quote)\(account)\(quote)\(delimiter)"

            data    = String(scheduler.nextOccurence)
            export  = "\(quote)\(data)\(quote)\(delimiter)"
            
            data    = String(scheduler.typeFrequence)
            export  = "\(quote)\(data)\(quote)\n"
            
        }
        return export
    }
    
}
