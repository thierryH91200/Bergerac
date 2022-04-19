import AppKit

extension RubriqueViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellView: NSView?
        if isHeader(item: item) {
            let cellView =  outlineView.makeView(withIdentifier: .RubriqueCell, owner: self) as! KSHeaderCellView3
            cellView.colorWell.isEnabled = false
            return cellView
        } else {
            cellView = outlineView.makeView(withIdentifier: .CategoryCell, owner: self)
        }
        return cellView

    }
    
    // indicates whether a given row should be drawn in the “group row” style.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool
    {
        return isHeader(item: item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        return true
    }
    
    func isHeader(item: Any) -> Bool {
        
        let treeNode = item as? NSTreeNode
        return treeNode?.representedObject is EntityRubric
//        return true
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {

        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true

        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true {
            ov!.animator().expandItem(nil, expandChildren: true)
        }
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {

        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true

        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true {
            ov!.animator().collapseItem(nil, collapseChildren:  true)
        }
    }

    func optionKeyPressed() -> Bool
    {
        let optionKey = NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option)
        return optionKey
    }


}

