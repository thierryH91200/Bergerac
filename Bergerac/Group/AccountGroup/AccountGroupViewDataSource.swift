    //
    //  AccountGroupViewController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import AppKit

extension AccountGroupViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        guard rootSourceListItem != nil else { return  0 }
        
        var count = 0
        if item == nil {
            //at root
            count = (rootSourceListItem.children?.count)!
        } else {
            count =  (item as? EntityAccount)?.children?.count ?? 0
        }
        return count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {

            let children = rootSourceListItem.children!
            return children[index]
        }
        
        let source = item as! EntityAccount
        let child = source.children![index]
        return child
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let source = item as! EntityAccount
        if (source.children?.count)! > 0 {
            return true
        } else {
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
        print("set object value called")
    }

}
