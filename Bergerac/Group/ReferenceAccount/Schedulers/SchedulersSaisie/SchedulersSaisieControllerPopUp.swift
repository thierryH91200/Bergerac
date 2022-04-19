import AppKit

extension SchedulersSaisieController {
    
    // # MARK: PopUp Rubrique - Catégorie
    func loadRubrique() {
        entityRubriques = Rubric.shared.getAllDatas()
        let  rubriqueMenu = NSMenu()
        for entityRubrique in entityRubriques
        {
            rubriqueMenu.addItem(rubriqueItemFor(entityRubrique) )
        }
        popUpRubrique.menu = rubriqueMenu
    }

    func rubriqueItemFor(_ value: EntityRubric) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value.name!
        menuItem.action = #selector(optionRubrique(sender:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionRubrique( sender: NSMenuItem)
    {
        loadCategory ()
    }
    
    // # MARK: PopUp Category
    func loadCategory () {
        let selectItem = popUpRubrique.selectedItem
        let  categorieMenu = NSMenu()
        let cat = selectItem?.representedObject as! EntityRubric
        let categories = cat.category?.allObjects as! [EntityCategory]
        
        for categorie in categories {
            categorieMenu.addItem( categoryItemFor(categorie) )
        }
        popUpCategorie.menu = categorieMenu
    }
    
    func categoryItemFor(_ value: EntityCategory) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value.name!
        menuItem.action = nil
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    // # MARK: PopUp ModePaiement
    func loadModePaiement () {
        let  modePaiementMenu = NSMenu()
        
        let modesPaiement = PaymentMode.shared.getAllDatas()
        
        for modePaiement in modesPaiement  {
            modePaiementMenu.addItem(modePaiementItemFor(modePaiement) )
        }
        popUpModePaiement.menu = modePaiementMenu
    }

    func modePaiementItemFor(_ value: EntityPaymentMode) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.title = value.name!
        menuItem.action = #selector(optionModePaiement(sender:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.representedObject = value
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionModePaiement( sender: NSMenuItem)
    {
    }
    
    // # MARK: PopUp Account
    func loadCompte () {
        let  transfertMenu = NSMenu()
        
        let comptes = Account.shared.getAllDatas()
        for compte in comptes where compte.isAccount == true
        {
            transfertMenu.addItem(compteItemFor(compte) )
        }
        var items = transfertMenu.items
        items.sort(by: { $0.title < $1.title })
        transfertMenu.removeAllItems()
        for item in items {
            transfertMenu.addItem(item)
        }
        popUpTransfert.menu = transfertMenu
    }
    
    fileprivate func compteItemFor(_ value: EntityAccount) -> NSMenuItem {
        var number = value.initAccount?.codeAccount!
        let menuItem = NSMenuItem()
        
        if value == currentAccount {
            number = "(no transfert)"
            menuItem.representedObject = nil
        } else {
            menuItem.representedObject = value
        }
        menuItem.title = number!
        menuItem.action = #selector(optionCompte(sender:))
        menuItem.target = self
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = true
        return menuItem
    }
    
    @objc func optionCompte( sender: NSMenuItem)
    {
        let selectItem = popUpTransfert.selectedItem
        let compte = selectItem?.representedObject as? EntityAccount
        
        entityCompteTransfert = compte
    }

}

