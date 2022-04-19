import AppKit


extension ListTransactionsController: NSMenuDelegate {

    // MARK: - Show Hide Columns
    func menuWillOpen( _ menu: NSMenu) {
        for menuItem in menu.items
        {
            let col = menuItem.representedObject as? NSTableColumn
            menuItem.state = (col?.isHidden)! ? .off : .on
        }
    }

    // MARK: - set up the table header context menu for choosing the columns.
    func createOutlineContextMenu()
    {
        let tableHeaderContextMenu = NSMenu(title: "Select Columns")

        tableHeaderContextMenu.delegate = self
        
        let dict = UserDefaults.standard.dictionary(forKey: kUserDefaultsKeyVisibleColumns)
        let dict1 = dict?[kUserDefaultsKeyVisibleColumns] as! [String : Bool]

        for column in outlineListView.tableColumns
        {
            let title = column.headerCell.title
            let item = tableHeaderContextMenu.addItem(withTitle: title, action: #selector(self.contextMenuSelected), keyEquivalent: "")
            
            item.target = self
            item.representedObject = column
            item.state = .on
            
            let isVisible = dict1[column.identifier.rawValue]!
            column.isHidden = isVisible
            item.state = column.isHidden ? .off : .on
        }
        self.outlineListView.headerView?.menu = tableHeaderContextMenu
    }
   
    // MARK: - contextMenuSelected
/// The outline action. `addItem( withTitle` specifies this func.
    @objc func contextMenuSelected(_ menuItem: NSMenuItem) {
        
        let column = menuItem.representedObject as? NSTableColumn
        let shouldHide = !column!.isHidden
        column?.isHidden = shouldHide
        menuItem.state = (column?.isHidden)! ? .off : .on
        
        let parentMenu = menuItem.menu
        
        var columnVisibilityDictionary = UserDefaults.standard.dictionary(forKey: kUserDefaultsKeyVisibleColumns)
        
        for column in outlineListView.tableColumns
        {
            columnVisibilityDictionary![column.identifier.rawValue] = !column.isHidden
        }
        let identifierCol = column?.identifier.rawValue
        let expenses = Localizations.General.Expenses
        let incomes = Localizations.General.Income
        let amount = Localizations.General.Amount

        if identifierCol == "depense" {
            columnVisibilityDictionary!["recette"] = menuItem.state == .on ? true : false
            columnVisibilityDictionary!["depense"] = menuItem.state == .on ? true : false
            
            let item = parentMenu?.item(withTitle: incomes)
            item?.state = menuItem.state
            
            columnVisibilityDictionary!["montant"] = menuItem.state == .on ? false : true
            let itemMontant = parentMenu?.item(withTitle: amount)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        
        if identifierCol == "recette" {
            columnVisibilityDictionary!["recette"] = menuItem.state == .on ? true : false
            columnVisibilityDictionary!["depense"] = menuItem.state == .on ? true : false
            
            let item = parentMenu?.item(withTitle: expenses)
            item?.state = menuItem.state

            columnVisibilityDictionary!["montant"] = menuItem.state == .on ? false : true
            let itemMontant = parentMenu?.item(withTitle: amount)
            itemMontant?.state = menuItem.state == .on ? .off : .on
        }
        
        if identifierCol == "montant" {
            columnVisibilityDictionary!["recette"] = false
            let itemIncome = parentMenu?.item(withTitle: incomes)
            itemIncome?.state = menuItem.state == .on ? .off : .on
            
            columnVisibilityDictionary!["depense"] = false
            let itemExpense = parentMenu?.item(withTitle: expenses)
            itemExpense?.state = menuItem.state == .on ? .off : .on
        }
        
        for column in outlineListView.tableColumns
        {
            column.isHidden = !((columnVisibilityDictionary![column.identifier.rawValue] )  as! Bool)
//            outlineListView.sizeToFit()
        }
        self.saveTableColumnDefaults()
    }
    
    /// Writes the selection to user defaults. Called every time an item is chosen.
    func saveTableColumnDefaults() {
        var dict = [String: Bool]()

        for column in self.outlineListView.tableColumns {
            let id = column.identifier.rawValue
            dict[id] = column.isHidden
        }
        UserDefaults.standard.set(dict, forKey: kUserDefaultsKeyVisibleColumns)
    }

}

