    //
    //  AccountGroupViewController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import Cocoa


    // MARK: - NSPasteboardItemDataProvider
extension AccountGroupViewController: NSPasteboardItemDataProvider {
    
    func pasteboard(_ pasteboard: NSPasteboard?,
                    item: NSPasteboardItem,
                    provideDataForType type: NSPasteboard.PasteboardType) {
        
        item.setString("Outline Pasteboard Item", forType: type)
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     draggingSession session: NSDraggingSession,
                     endedAt screenPoint: NSPoint,
                     operation: NSDragOperation) {
        
        self.draggedNodes = nil
        print("Drag session ended")
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     draggingSession session: NSDraggingSession,
                     willBeginAt screenPoint: NSPoint,
                     forItems draggedItems: [Any]) {
        
        print("Drag session begin")
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     writeItems items: [Any],
                     to pasteboard: NSPasteboard) -> Bool {
        
        print("writeItems")
        var result = true
        draggedNodes = items as? [EntityAccount]
        //for intra-NSOV drags, we do not attach pasteboard data
        pasteboard.setData(nil, forType: NSPasteboard.PasteboardType(rawValue: REORDER_PASTEBOARD_TYPE))
        
        let item = items.first as! EntityAccount
        if item.isHeader == true {
            result = false
        }
        return result
    }
    
    // -------------------------------------------------------------------------------
    //    outlineView:acceptDrop:item:childIndex
    //
    //       Cette méthode est appelée lorsque la souris est libérée sur une vue hiérarchique
    //    qui a précédemment décidé d'autoriser une suppression via la méthode validateDrop.
    //    La source de données doit incorporer les données  à cet instant.
    //    'index' est l'emplacement où insérer les données en tant qu'enfant de 'item',
    //    et ce sont les valeurs précédemment définies dans la méthode validateDrop:.
    //
    // -------------------------------------------------------------------------------
    // Here's what we do when the item is actually dropped...
    func outlineView(_ outlineView: NSOutlineView,
                     acceptDrop info: NSDraggingInfo,
                     item: Any?,
                     childIndex index: Int) -> Bool {
        
        if draggedNodes != nil {
            var fixedIndex = index
            if index == -1 {
                fixedIndex = 0
            }
            
            print("index : ", index)
            var item1: EntityAccount!
            if item != nil {
                item1 = item as? EntityAccount
                if item1.isFolder == false && item1.isHeader == false {
                    item1 = item1.parent!
                }
                makeItemsChildrenOfItem(draggedNodes!, parentItem: item1, index: fixedIndex)
            }
            
            anSideBar.reloadData()
            self.anSideBar.expandItem(nil, expandChildren: true)
            
            let row = anSideBar.row(forItem: draggedNodes![0])
            anSideBar.selectRowIndexes([row  ], byExtendingSelection: true)
            return true
        }
        return false
    }
    
    func makeItemsChildrenOfItem(_ items: [EntityAccount], parentItem: EntityAccount, index: Int) {
        for item in items {
            item.parent = nil
        }
        print("makeItemsChildrenOfItem index : ", index, "   ", parentItem.name ?? "name")
        let indices = IndexSet(integersIn: index ..< index + items.count)
        parentItem.mutableOrderedSetValue(forKey: "children").insert(items, at: indices)
    }
    
    // -------------------------------------------------------------------------------
    //    outlineView:validateDrop:proposedItem:proposedChildrenIndex:
    //
    //    This method is used by NSOutlineView to determine a valid drop target.
    // -------------------------------------------------------------------------------
    func outlineView(_ outlineView: NSOutlineView,
                     validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?,
                     proposedChildIndex index: Int) -> NSDragOperation {
                
        var result = NSDragOperation()

        if item == nil {
            // no item to drop on
            result = .generic
        } else {

            let entityAccount = item as? EntityAccount
            if draggedNodes != nil {

                let parent = draggedNodes![0].parent
                let count = parent?.children?.count

                if count == index {
                    result =  NSDragOperation()
                }

                if entityAccount?.isHeader == true {
                    result = .every
                } else if entityAccount == rootSourceListItem && index != -1 {
                    result =  .move
                } else {
                    print("result =  NSDragOperation()")
                    result =  NSDragOperation()
                }
            }
        }
        print("validate drop called on source list : ", result.rawValue)
        return result
    }
    
}
