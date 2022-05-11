import AppKit

//var groupedSorted = [ (key: String, value:  [ String :  [IdOperations]])]()

// MARK: NSTableViewDelegate
extension ListTransactionsController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
//        outlineView.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.sequentialColumnAutoresizingStyle
        
        if let folderItem = item as?  TrackingMonth {
            return trackingFolderYear( outlineView: outlineView, folderItem: folderItem)
        }
        
        if let folderItem = item as? TrackingIdTransactions  {
            return trackingFolderMonth(outlineView: outlineView, folderItem: folderItem)
        }
        
        if let itemSubs = item as? TrackingSubOperations {
            return manySubOperations(outlineView: outlineView, tableColumn: tableColumn, item: itemSubs)
        }
        
        if let itemSub = item as? TrackingSubOperation {
            return oneSubOperation(outlineView: outlineView, tableColumn: tableColumn, item: itemSub)
        }
        return nil
    }

    
// MARK: - trackingFolderYear
    func trackingFolderYear(outlineView: NSOutlineView, folderItem : TrackingMonth) -> NSView? {
        
        var cellView: KSHeaderCellView?
        
        cellView = outlineView.makeView(withIdentifier: .FeedCellYear, owner: self) as? KSHeaderCellView
        cellView?.textField?.stringValue = folderItem.year
        cellView?.textField?.textColor = .labelColor
        cellView?.fillColor = .lightGray
        return cellView
    }
    
// MARK: - trackingFolderMonth
    func trackingFolderMonth(outlineView: NSOutlineView, folderItem : TrackingIdTransactions) -> NSView? {
        
        var cellView: KSHeaderCellView?
        
        let formatterDate: DateFormatter = {
            let fmt = DateFormatter()
            fmt.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM yyyy", options: 0, locale: Locale.current)
            return fmt
        }()
        
        var title  = NSMutableAttributedString()
        var dateFormatted  = ""
        var dateString = ""
        var strTitle = ""
        
        // Header
        if let numericSection = Int(folderItem.month)
        {
            var components = DateComponents()
            components.year = numericSection / 100
            components.month = numericSection % 100
            
            if let date = Calendar.current.date(from: components) {
                dateString = formatterDate.string(from: date)
                dateFormatted = dateString.padding(toLength: 20, withPad: " ", startingAt: 0)
            }
            let nbOperations = folderItem.transactions.count
            let transactionsString = "\(nbOperations) opérations"
            let transactionsFormatted = transactionsString.padding(toLength: 30, withPad: " ", startingAt: 0)
            
            var expenses = 0.0
            var incomes = 0.0
            var amount = 0.0
            
            for itemF in folderItem.transactions
            {
                amount = itemF.entityTransaction.amount
                if amount < 0.0 {
                    expenses += amount
                } else {
                    incomes += amount
                }
            }
            
            let expense = Localizations.General.Expenses
            let income  = Localizations.General.Income
            
            let expenseStr = formatterPrice.string(from: NSDecimalNumber(value: expenses))
            let expenseFormatted = "\(expense) : \( expenseStr!)".padding(toLength: 30, withPad: " ", startingAt: 0)
            
            let incomeStr = formatterPrice.string(from: NSDecimalNumber(value: incomes))
            let incomeFormatted = "\(income) : \( incomeStr!)".padding(toLength: 30, withPad: " ", startingAt: 0)
            
            let totalStr = formatterPrice.string(from: NSDecimalNumber(value: incomes + expenses))
            let totalFormatted = "Total : \(totalStr!)".padding(toLength: 30, withPad: " ", startingAt: 0)
            
            let paragraphStyle = NSMutableParagraphStyle()
            let terminator = NSTextTab.columnTerminators(for: NSLocale.current)
            // Adjust the location as needed for your text
            let tab = NSTextTab(textAlignment: .left, location: 72.0 * 4, options: [NSTextTab.OptionKey.columnTerminators: terminator])
            paragraphStyle.tabStops = [tab]

            let attributedString = NSMutableAttributedString(string: dateString + "\t" + transactionsString, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            title = attributedString

            strTitle = "     " + dateFormatted + transactionsFormatted + expenseFormatted + incomeFormatted + totalFormatted
        }
        
        cellView = outlineView.makeView(withIdentifier: .FeedCellMonth, owner: self) as? KSHeaderCellView
        
        cellView?.textField?.attributedStringValue = title
        cellView?.textField?.stringValue = strTitle
        cellView?.textField?.textColor = .labelColor
        cellView?.backgroundStyle = .normal
        
//        let attribute: [NSAttributedString.Key: Any] = [
//            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .bold),
//            .foregroundColor: NSColor.black]

        return cellView
    }
    
    func oneSubOperation(outlineView: NSOutlineView, tableColumn: NSTableColumn?, item: TrackingSubOperation) -> NSView? {
        
//        let currentPurchase = viewModel.purchases[row]

        var cellView: NSTableCellView?
        
        let identifier = tableColumn!.identifier
        guard let propertyEnum = ListeOperationsDisplayProperty(rawValue: identifier.rawValue) else { return nil }
        
        let splitOperations = item
        
        if identifier.rawValue == "datePointage"
        {
            cellView = outlineView.makeView(withIdentifier: .sousOpCell, owner: self) as? NSTableCellView
        } else
        {
            cellView = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView
        }
        
        let textField = (cellView?.textField!)!
        textField.stringValue = ""
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        switch propertyEnum
        {
        case .dateTransaction, .datePointage, .bankStatement, .statut, .liee, .mode, .solde, .checkNumber:
            textField.stringValue = ""
            
        case .rubric:
            textField.stringValue = splitOperations.category?.rubric?.name ?? ""
        case .category:
            textField.stringValue = splitOperations.category?.name ?? ""
        case .comment:
            textField.stringValue = splitOperations.libelle ?? ""
        case .amount:
            let price = splitOperations.amount as NSNumber
            let formatted = formatterPrice.string(from: price)
            textField.stringValue = formatted!
            paragraph.alignment = .right
        case .depense:
            var price: NSNumber = 0.0
            var formatted = ""
            if splitOperations.amount < 0 {
                price = splitOperations.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            paragraph.alignment = .right
        case .recette:
            var price: NSNumber = 0.0
            var formatted = ""
            if splitOperations.amount > 0 {
                price = splitOperations.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            paragraph.alignment = .right
        }
        
        colorSousOperations (quake: item, textField: textField, propertyEnum: propertyEnum )
        return cellView
    }
    
    func manySubOperations(outlineView: NSOutlineView, tableColumn: NSTableColumn?, item: TrackingSubOperations) -> NSView? {
        
        var cellView: CategoryCellView?
        
        guard tableColumn != nil else { return nil }
        
        let identifier = tableColumn!.identifier
        guard let propertyEnum = ListeOperationsDisplayProperty(rawValue: identifier.rawValue) else { return nil }
        let quake = item.entityTransaction
        let sousOperations = item.entityTransaction.sousOperations?.allObjects as! [EntitySousOperations]
        
        if identifier.rawValue == "datePointage"
        {
            if sousOperations.count == 1 {
                cellView = outlineView.makeView(withIdentifier: .FeedCell, owner: self) as? CategoryCellView
            } else {
                cellView = outlineView.makeView(withIdentifier: .sousOpCell, owner: self) as? CategoryCellView
            }
        } else
        {
            cellView = outlineView.makeView(withIdentifier: identifier, owner: self) as? CategoryCellView
        }
        
        cellView?.oldFont = nil
        cellView?.oldColor = nil

        let textField = (cellView?.textField!)!
        textField.stringValue = ""
        
        var alignment : NSTextAlignment! = .left
        
        switch propertyEnum
        {
        case .dateTransaction:
            alignment = .center
            var time = Date()
            if quake.dateOperation != nil {
                time = quake.dateOperation!
            }
            let formattedDate = formatterDate.string(from: time)
            textField.stringValue = formattedDate
            
        case .datePointage:
            alignment = .center
            var time = Date()
            if quake.datePointage != nil {
                time = quake.datePointage!
            }
            let formattedDate = formatterDate.string(from: time)
            textField.stringValue = formattedDate
            

        case .rubric:
            if sousOperations.count == 1 {
                textField.stringValue = sousOperations[0].category?.rubric?.name ?? ""
            } else {
                cellView = CrossHatchView()
                textField.stringValue = ""
            }
            
        case .category:
            if sousOperations.count == 1 {
                textField.stringValue = sousOperations[0].category?.name ?? ""
            } else {
                cellView = CrossHatchView()
                textField.stringValue = ""
            }
            
        case .comment:
            if sousOperations.count == 1 {
                textField.stringValue = sousOperations[0].libelle ?? ""
            } else {
                cellView = CrossHatchView()
                textField.stringValue = ""
            }
            alignment = .left
            
        case .mode:
            alignment = .left
            textField.stringValue = quake.paymentMode?.name ?? ""
            
        case .amount:
            let price = quake.amount as NSNumber
            let formatted = formatterPrice.string(from: price)
            textField.stringValue = formatted!
            alignment = .right
            
        case .depense:
            var price: NSNumber = 0.0
            var formatted = ""
            if quake.amount < 0 {
                price = quake.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            alignment = .right
            
        case .recette:
            var price: NSNumber = 0.0
            var formatted = ""
            if quake.amount > 0 {
                price = quake.amount as NSNumber
                formatted = formatterPrice.string(from: price)!
            }
            textField.stringValue = formatted
            alignment = .right
            
        case .bankStatement:
            alignment = .center
            if quake.bankStatement != 0 {
                textField.doubleValue = quake.bankStatement
            } else {
                textField.stringValue = ""
            }

        case .solde:
            let solde = quake.solde
            let price = solde as NSNumber
            let formatted = formatterPrice.string(from: price)
            textField.stringValue = formatted!
            alignment = .right
            
        case .statut:
            var label = ""
            label = Statut.TypeOfStatut(rawValue: Int16(quake.statut))!.label
            alignment = .center
            textField.stringValue = label
            
        case .liee:
            if let liee = quake.operationLiee {
                textField.stringValue = liee.account?.name ?? ""
            } else {
                textField.stringValue = ""
            }
            
        case .checkNumber:
            if let number = quake.checkNumber {
                textField.stringValue = String(number)
            } else {
                textField.stringValue = ""
            }
            alignment = .center
        }
        
        textField.alignment = alignment
        colorText (quake: quake, textField: textField)
        return cellView
    }
    
    
    // Returns the height in points of the row containing item.
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat
    {
        if isSourceGroupItem(item) == false {
            return 18.0
        } else {
            return 16.0
        }
    }
    
    // indicates whether a given row should be drawn in the “group row” style.
    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {
        if item is TrackingMonth {
            return true
        }
        if item is TrackingIdTransactions {
            return true
        }
        return false
    }
    
    // Show the expander triangle for group items..
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool
    {
        return isSourceGroupItem(item)
    }
    
    // Returns a Boolean value that indicates whether the outline view should select a given item.
    public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        if item is TrackingSubOperations {
            return true
        }
        return false
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        
        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true

        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true && listTransactions.isEmpty == false {
            ov!.animator().expandItem(nil, expandChildren: true)
        }
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {
        
        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true

        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true && listTransactions.isEmpty == false {
            ov!.animator().collapseItem(nil, collapseChildren:  true)
        }
    }

    func optionKeyPressed() -> Bool
    {
        let optionKey = NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option)
        return optionKey
    }

}
