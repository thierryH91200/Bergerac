import AppKit


// MARK: NSOutlineViewDelegate
extension TransactionViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        var cellView: CategoryCellView?

        if  item is EntitySousOperations {

            cellView = outlineView.makeView(withIdentifier: .FeedCellHeader, owner: self) as? CategoryCellView

            let amount = (item as! EntitySousOperations).amount as NSNumber
            let formatted = formatterPrice.string(from: amount)

            foregroundColor =  (item as! EntitySousOperations).category?.rubric?.color as! NSColor

            let str = (item as! EntitySousOperations).libelle! + "  " + formatted!
            cellView?.textField!.stringValue = str
            cellView?.textField?.textColor = foregroundColor

        } else {
            
            cellView = outlineView.makeView(withIdentifier: .FeedCellHeader, owner: self) as? CategoryCellView

            cellView?.textField!.stringValue = item as! String
            cellView?.textField?.textColor = foregroundColor
        }
        cellView?.oldFont = nil
        cellView?.oldColor = nil

        return cellView
    }
    
}

// MARK: NSOutlineViewDataSource
extension TransactionViewController: NSOutlineViewDataSource {
    
    // Returns the number of child items encompassed by a given item.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // Root
        if item == nil {
            return splitTransactions.count
        }
        // child
        return 4
    }
    
    // Returns the child item at the specified index of a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        // Root
        if item == nil {
            let splitTransaction = splitTransactions[index]
            return splitTransaction
        }
        
        // child
        var child = ""
        let splitTransaction = item as! root
        switch index {
        case 0:
            child = splitTransaction.libelle!
        case 1:
            child = (splitTransaction.category?.rubric!.name)!
        case 2:
            child = (splitTransaction.category?.name)!
        case 3:
            let amount = splitTransaction.amount as NSNumber
            let priceFormatted = formatterPrice.string(from: amount)
            child = priceFormatted!

        default:
            child = ""
        }
        return child
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return isSourceGroupItem(item)
    }
    
    func isSourceGroupItem(_ item: Any) -> Bool
    {
        if item is root {
            return true
        }
        return false
    }
    
    //    Show the expander triangle for group items..
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool
    {
        return isSourceGroupItem(item)
    }
    
    //  Returns a Boolean value that indicates whether the outline view should select a given item.
    public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        if item is root {
            return true
        }
        return false
    }
    
}
