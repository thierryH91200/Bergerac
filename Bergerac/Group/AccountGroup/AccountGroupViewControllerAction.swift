    //
    //  AccountGroupViewController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import AppKit

    // MARK: - NSMenuDelegate
extension AccountGroupViewController: NSMenuDelegate {
    
    func menuWillOpen( _ menu: NSMenu) {
        
        let index = anSideBar.selectedRow
        if let item = anSideBar.item(atRow: index) as? EntityAccount {
            
            for menuItem in menu.items
            {
                menuItem.isHidden =  true
                if item.isHeader == true, menuItem.tag == 0 {
                    menuItem.isHidden =  false
                }
                if item.isAccount == true, menuItem.tag == 1 {
                    menuItem.isHidden =  false
                }
            }
        }
    }
    
    @IBAction func editAccount(_ sender: Any) {
        
        let index = anSideBar.selectedRow
        if let item = anSideBar.item(atRow: index) as? EntityAccount
        {
            if item.isAccount == true {
                accountModalWindowController = AccountModalWindowController()
                accountModalWindowController.account = item
                accountModalWindowController.edition = true
                
                let windowAdd = accountModalWindowController.window!
                let windowApp = self.view.window
                windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
                    
                    switch returnCode {
                    case .OK:
                        
                        let libelleAccount  = self.accountModalWindowController.libelleCompte.stringValue
                        let soldeInitial    = self.accountModalWindowController.soldeInitial.doubleValue
                        let nomTitulaire    = self.accountModalWindowController.nomTitulaire.stringValue
                        let prenomTitulaire = self.accountModalWindowController.prenomTitulaire.stringValue
                        let numAccount      = self.accountModalWindowController.numCompte.stringValue
                        let nameImage       = self.accountModalWindowController.imageView.image?.name()
                        let type            = self.accountModalWindowController.typeAccount.indexOfSelectedItem
                        
                        item.name                     = libelleAccount
                        item.initAccount?.realise     = soldeInitial
                        item.identity?.name           = nomTitulaire
                        item.identity?.surName        = prenomTitulaire
                        item.initAccount?.codeAccount = numAccount
                        item.nameImage                = nameImage
                        item.type                     = Int16(type)
                        
                            //                        let undo = self.undoManager!
                            //                        (undo.prepare(withInvocationTarget: item) as AnyObject).setValue(item, forKeyPath: "item")
                        
                            //                        self.rootSourceListItem.clear()
                        
                        self.anSideBar.reloadData()
                        self.anSideBar.expandItem(nil, expandChildren: true)
                        self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                        
                    case .cancel:
                        break
                    default:
                        break
                    }
                    self.accountModalWindowController = nil
                })
                
            }
            
            if item.isHeader == true {
                groupModalWindowController = GroupModalWindowController()
                groupModalWindowController.account = item
                groupModalWindowController.edition = true
                
                let windowAdd = groupModalWindowController.window!
                let windowApp = self.view.window
                windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
                    
                    switch returnCode {
                    case .OK:
                        
                        let name = self.groupModalWindowController.nameGroup.stringValue
                        item.name = name
                        
                            //                        let undo = self.undoManager!
                            //                        (undo.prepare(withInvocationTarget: item) as AnyObject).setValue(item, forKeyPath: "item")
                        
                            //                        self.rootSourceListItem.clear()
                        
                        self.anSideBar.reloadData()
                        self.anSideBar.expandItem(nil, expandChildren: true)
                        self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                        
                    case .cancel:
                        break
                        
                    default:
                        break
                    }
                    self.groupModalWindowController = nil
                })
            }
        }
    }
    
    @IBAction func addAccount(_ sender: Any) {
        
            //        let index = anSideBar.selectedRow
            //        let item = anSideBar.item(atRow: index) as? EntityAccount
        
        
        self.accountModalWindowController = AccountModalWindowController()
        let windowAdd = accountModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let nameAccount  = self.accountModalWindowController.libelleCompte.stringValue
                let soldeInitial = self.accountModalWindowController.soldeInitial.doubleValue
                let nom          = self.accountModalWindowController.nomTitulaire.stringValue
                let prenom       = self.accountModalWindowController.prenomTitulaire.stringValue
                let numAccount   = self.accountModalWindowController.numCompte.stringValue
                let nameImage    = self.accountModalWindowController.imageView.image?.name()!
                let type         = self.accountModalWindowController.typeAccount.indexOfSelectedItem
                
                let compte   = Account.shared.create(nameAccount: nameAccount, nameImage: nameImage!, idName: nom, idPrenom: prenom, numAccount: numAccount)
                compte.type = Int16(type)
                compte.initAccount?.realise = soldeInitial
                
                    //                let undo = self.undoManager!
                    //                (undo.prepare(withInvocationTarget: compte) as AnyObject).setValue(compte, forKeyPath: "compte")
                
                let list = self.rootSourceListItem.children?[0] as? EntityAccount
                list?.insertIntoChildren(compte, at: 0)
                
                    //                self.rootSourceListItem.clear()
                
                self.anSideBar.reloadData()
                self.anSideBar.expandItem(nil, expandChildren: true)
                self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                
            case .cancel:
                print("Cancel button tapped in Custom addAccount Sheet")
                
            default:
                break
            }
            self.accountModalWindowController = nil
        })
        
    }
    
    @IBAction func addGroupAccount(_ sender: Any) {
        
        let context = mainObjectContext
        
        self.groupModalWindowController = GroupModalWindowController()
        let windowAdd = groupModalWindowController.window!
        let windowApp = self.view.window
        windowApp?.beginSheet( windowAdd, completionHandler: {(_ returnCode: NSApplication.ModalResponse) -> Void in
            
            switch returnCode {
            case .OK:
                
                let name = self.groupModalWindowController.nameGroup.stringValue
                
                    //create source list headers
                let header = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: context!) as! EntityAccount
                header.isHeader = true
                header.name = name
                header.uuid = UUID()
                header.parent = self.rootSourceListItem
                
                    //                let undo = self.undoManager!
                    //                (undo.prepare(withInvocationTarget: header) as AnyObject).setValue(header, forKeyPath: "header")
                
                    //                self.rootSourceListItem.clear()
                
                self.anSideBar.reloadData()
                self.anSideBar.expandItem(nil, expandChildren: true)
                self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
                
            case .cancel:
                break
                
            default:
                break
            }
            self.groupModalWindowController = nil
        })
        
    }
    
    @IBAction func removeAction(_ sender: Any) {
        
        let alert = NSAlert()
        alert.messageText = Localizations.GroupeAccount.RemoveAlert.MessageText
        alert.informativeText = Localizations.GroupeAccount.RemoveAlert.InformativeText
        alert.addButton(withTitle: Localizations.GroupeAccount.RemoveAlert.Delete)
        alert.addButton(withTitle: Localizations.GroupeAccount.RemoveAlert.Cancel)
        alert.alertStyle = NSAlert.Style.informational
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                
                print("Document 🗑")
                
                self.deleteSelection()
                
                self.rootSourceListItem = Account.shared.getRoot().first!
                
                self.anSideBar.reloadData()
                self.anSideBar.expandItem(nil, expandChildren: true)
                self.anSideBar.selectRowIndexes([1], byExtendingSelection: false)
            }
        })
    }
    
    func deleteSelection() {
        
        let context = mainObjectContext
        let selected = anSideBar.selectedRowIndexes
        guard selected.isEmpty == false else { return }
        
        for selectedRow in selected {
            
            let item = anSideBar.item(atRow: selectedRow) as? EntityAccount
            if item?.isHeader == true {
                let entities = item?.children?.array as! [EntityAccount]
                
                for child in entities {
                    context!.delete(child)
                }
            }
            context!.delete(item!)
        }
        
            //        let sourceListItems = selected.map({ return anSideBar.item(atRow: $0) })
            //        for item in sourceListItems {
            //
            //            let entitie = item as! EntityAccount
            //            if entitie.isHeader == true {
            //                let entities = entitie.children?.array as! [EntityAccount]
            //
            //                for child in entities {
            //                    context!.delete(child)
            //                }
            //            }
            //            context!.delete(entitie)
            //        }
    }
    
}

