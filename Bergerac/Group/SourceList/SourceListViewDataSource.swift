import AppKit


extension SourceListViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        var count = 0
        if item == nil {
            //at root
            count =  datas.count
        } else {
            count =  (item as? Datas)?.children.count ?? 0
        }
        return count
    }

    /// Returns the child item at the specified index of a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return datas[index]
        }
        
        let source = item as! Datas
        let child = source.children[index]
        return child
    }
    
    // ok
    /// indicates whether a given row should be drawn in the “group row” style.
    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {
        return isSourceGroupItem(item)
    }
    
    /// Returns a Boolean value that indicates whether the a given item is expandable.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let source = item as? Datas
        if source?.children.count ?? 0 > 0 {
            return true
        } else {
            return false
        }

    }
    
    /// Invoked by outlineView to return the data object associated with the specified item.
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let item = item as? Datas
        {
            return item
        }
        if let item = item as? Children
        {
            return item
        }
        return nil
    }
    
    func isSourceGroupItem(_ item: Any) -> Bool
    {
        if item is Datas {
            return true
        }
        return false
    }
}
