//
//  OperationViewControllerAction.swift
//  Bergerac
//
//  Created by thierry hentic on 18/09/2019.
//  Copyright © 2019 thierryH24. All rights reserved.
//

import AppKit

extension TransactionViewController  {
    
    @IBAction func annulerAction(_ sender: Any) {
        self.resetOperation()
    }
    
    @IBAction func addSousOperation(_ sender: Any) {
        
        let context = mainObjectContext
        
        var entitySousOperation = NSEntityDescription.insertNewObject(forEntityName: "EntitySousOperations", into: context!) as! EntitySousOperations

        self.sousOperationModalWindowController = SousOperationModalWindowController()
        self.sousOperationModalWindowController.entitySousOperation = entitySousOperation
        
        let windowAdd = sousOperationModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                self.addView.isHidden = true
                
                entitySousOperation = self.sousOperationModalWindowController.entitySousOperation!
                self.entityTransactions.first?.addToSousOperations(entitySousOperation)

                self.buttonSave.isEnabled = true
                self.splitTransactions.append(entitySousOperation)

                self.outlineViewSSOpe.reloadData()
                self.removeButton.isEnabled = true
                                
                self.calcAmount()
                self.updateChartData()
                self.setDataCount()
                                
                self.delegate?.getAllData()
                self.delegate?.reloadData(true, false)
                
                NotificationCenter.send(.updateBalance)

            case .cancel:
                break
                
            default:
                break
            }
            self.sousOperationModalWindowController = nil
        })
    }
    
    @IBAction func editSubOperation(_ sender: Any) {
        
        let selectRow = outlineViewSSOpe.selectedRow
        guard selectRow != -1 else { return }
        let item = outlineViewSSOpe.item(atRow: selectRow) as? EntitySousOperations
        
        self.sousOperationModalWindowController = SousOperationModalWindowController()
        self.sousOperationModalWindowController.entitySousOperation = item
        self.sousOperationModalWindowController.edition = true
        
        let windowAdd = self.sousOperationModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let entitySousOperation = self.sousOperationModalWindowController.entitySousOperation!
                self.entityTransactions.first?.removeFromSousOperations(item!)
                self.entityTransactions.first?.addToSousOperations(entitySousOperation)
                self.splitTransactions = self.entityTransactions.first?.sousOperations?.allObjects as! [EntitySousOperations]
                self.outlineViewSSOpe.reloadData()

                self.calcAmount()
                self.updateChartData()
                self.setDataCount()
                
                self.delegate?.getAllData()
                self.delegate?.reloadData(true, false)
                
                NotificationCenter.send(.updateBalance)
//                self.resetOperation()

            case .cancel:
                break
                
            default:
                break
            }
            self.sousOperationModalWindowController = nil
        })
    }
    
    @IBAction func removeSubOperation(_ sender: Any) {
        
        let selectRow = outlineViewSSOpe.selectedRow
        guard selectRow != -1 else { return }
        
        let alert = NSAlert()

        alert.messageText = Localizations.GroupeAccount.RemoveAlert.MessageText
        alert.informativeText = Localizations.GroupeAccount.RemoveAlert.InformativeText
        alert.addButton(withTitle: Localizations.GroupeAccount.RemoveAlert.Delete)
        alert.addButton(withTitle: Localizations.GroupeAccount.RemoveAlert.Cancel)
        alert.alertStyle = .warning
        
        alert.beginSheetModal(for: self.outlineViewSSOpe.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                print("Document 🗑")
                self.deleteSelection()
                
                if self.splitTransactions.isEmpty == true {
                    self.buttonSave.isEnabled = false
                }
                
                self.outlineViewSSOpe.reloadData()
                self.outlineViewSSOpe.expandItem(nil, expandChildren: true)
                self.outlineViewSSOpe.selectRowIndexes([1], byExtendingSelection: false)
                
                self.calcAmount()
                
                self.updateChartData()
                self.setDataCount()
                
                self.delegate?.getAllData()
                self.delegate?.reloadData(true, false)
                
                NotificationCenter.send(.updateBalance)
                self.resetOperation()
            }
        })
    }
    
    func deleteSelection() {
        
        let context = mainObjectContext
        let selected = outlineViewSSOpe.selectedRowIndexes
        
        let sourceListItems = selected.map({ return outlineViewSSOpe.item(atRow: $0) })
        for item in sourceListItems {
            
            let entitie = item as! EntitySousOperations
            context!.delete(entitie)
        }
        self.outlineViewSSOpe.reloadData()
    }
    
    @IBAction func simpleClickedItem(_ sender: NSOutlineView) {
        //1
        let item = sender.item(atRow: sender.clickedRow)
        
        //2
        if item is EntitySousOperations {
            //3
            if sender.isItemExpanded(item) {
                sender.collapseItem(item)
            } else {
                sender.expandItem(item)
            }
        }
    }
    
    func calcAmount() {
        var amount = 0.0
        for sousOperation in self.splitTransactions {
            amount += sousOperation.amount
        }
        
        self.textFieldMontant.doubleValue = abs(amount)
        self.textFieldMontant.placeholderString = ""
        self.textFieldMontant.textColor = amount < 0 ? NSColor.red : NSColor.green
    }
}
