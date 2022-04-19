import AppKit


extension SourceListViewController: NSOutlineViewDelegate {
        
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        if let section = item as? Datas
        {
            let cell = outlineView.makeView(withIdentifier: .FeedCellHeader, owner: self) as? KSHeaderCellView

            cell?.fillColor = self.colorBackGround
            cell?.textField!.stringValue = section.name.uppercased()
            cell?.textField!.textColor = NSColor.labelColor

            let nameIcon = section.icon
            let config = NSImage.SymbolConfiguration(scale: .large)
            let image = NSImage(systemSymbolName: nameIcon, accessibilityDescription: "pie")?.withSymbolConfiguration(config)

            cell?.imageView!.image =   image
            return cell
        } else if let account = item as? Children
        {
            let cell = outlineView.makeView(withIdentifier: .FeedCell, owner: self) as? NSTableCellView
            
            let nameIcon = account.icon
            let config = NSImage.SymbolConfiguration(scale: .large)
            let image = NSImage(systemSymbolName: nameIcon, accessibilityDescription: nil)?.withSymbolConfiguration( config)
            
            cell?.imageView!.image       = image
            cell?.textField!.stringValue = account.name
            cell?.textField!.textColor = NSColor.labelColor
            return cell
        }
        return nil
    }

    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return MyNSTableRowView()
    }
    
    /// Returns a Boolean value that indicates whether the outline view should select a given item.
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool
    {
        return !isSourceGroupItem(item)
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true
        
        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true {
            ov!.animator().collapseItem(nil, collapseChildren: true)
        }
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        let ov = notification.object as? NSOutlineView
        ov!.autosaveExpandedItems = true

        let optionKeyIsDown = optionKeyPressed()
        if optionKeyIsDown == true {
            ov!.animator().expandItem(nil, expandChildren: true)
        }
    }
    
    func optionKeyPressed() -> Bool
    {
        let optionKey = NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option)
        return optionKey
    }

}
