import AppKit

//var groupedSorted = [ (key: String, value:  [ String :  [IdOperations]])]()

extension ListTransactionsController: NSOutlineViewDataSource {
    
    //Returns the number of child items encompassed by a given item.
    fileprivate func extractedFunc(_ item: Any?) -> Int {
        // Root number year
        if item == nil {
            let nbYear = groupedSorted.count
            return nbYear
        }
        // Root number month
        if let folderItem = item as? TrackingMonth  {
            let nbMonths = folderItem.allMonth.count
            return nbMonths
        }
        // number EntityOperations
        if let folderItem = item as? TrackingIdTransactions {
            let nbIdOperations = folderItem.transactions.count
            return nbIdOperations
        }
        // number EntitySousOperations
        if let idOperation = item as? TrackingSubOperations {
            let nbSousOperations = idOperation.entityTransaction.sousOperations?.count ?? 0
            return nbSousOperations
        }
        debugPrint("numberOfChildrenOfItem : BAD ITEM")
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
                        
        return extractedFunc(item)
    }
    
    // Returns the child item at the specified index of a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        // Root year
        if item == nil {
            let child = groupedSorted[index]
            return child
        }
        // Root month
        if let folderItem = item as? TrackingMonth {
            let folder = folderItem.allMonth
            let val = folder[index]
            return val
        }
        // EntityOperations
        if let folderItem = item as? TrackingIdTransactions  {
            let idOperations = folderItem.transactions[index]
            return idOperations
        }
        // EntitySousOperations
        if let idOperation = item as? TrackingSubOperations {
            let sousOperations = idOperation.entityTransaction.sousOperations?.allObjects as! [EntitySousOperations]
            return sousOperations[index]
        }
        debugPrint("child index : BAD ITEM")
        return "child index : BAD ITEM"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return isSourceGroupItem(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem: Any?) -> Any? {
        
        if let item = byItem as? (key: String, value: [Transaction]) {
            return item.key
        }
        if let item = byItem as? EntityTransactions {
            return item
        }
        return "???????"
    }
    
    func isSourceGroupItem(_ item: Any) -> Bool
    {
        if item is TrackingYear {
            return true
        }
        if item is TrackingMonth {
            return true
        }
        if item is TrackingIdTransactions {
            return true
        }

        if item is TrackingSubOperations {

            let idOperation = item as! TrackingSubOperations
            let count = (idOperation.entityTransaction.sousOperations?.count) ?? 0
            if count > 1 {
                return true
            }
        }
        return false
    }
    
}
