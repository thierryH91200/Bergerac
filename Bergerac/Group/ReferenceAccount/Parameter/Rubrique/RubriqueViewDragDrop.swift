import AppKit

extension RubriqueViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView,
                     draggingSession session: NSDraggingSession,
                     endedAt screenPoint: NSPoint,
                     operation: NSDragOperation) {
        
        self.draggedNode = nil
        anTreeController.rearrangeObjects()
        print("Drag session ended")
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     draggingSession session: NSDraggingSession,
                     willBeginAt screenPoint: NSPoint,
                     forItems draggedItems: [Any]) {
        
        draggedNode = draggedItems[0] as AnyObject?
        session.draggingPasteboard.setData(Data(), forType: NSPasteboard.PasteboardType( "DragType"))
        print("Drag session begin")

    }

    func outlineView(_ outlineView: NSOutlineView,
                     writeItems items: [Any],
                     to pasteboard: NSPasteboard) -> Bool {
        pasteboard.declareTypes(dragType, owner: self)
        draggedNode = items[0]
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     acceptDrop info: NSDraggingInfo,
                     item: Any?,
                     childIndex index: Int) -> Bool {
        
        let treeNode = item as? NSTreeNode
        var srcManagedObject = treeNode?.representedObject as? NSManagedObject
        
        var result = srcManagedObject is EntityRubric
        if result == false {
            srcManagedObject = srcManagedObject?.value(forKey: "rubric") as? NSManagedObject
            result = srcManagedObject is EntityRubric
        }

        let draggedNode1 = draggedNode as? NSTreeNode
        let dstManagedObject = draggedNode1?.representedObject as! NSManagedObject
        result = dstManagedObject is EntityCategory

        if result == false {
            return false
        }
        
        dstManagedObject.setValue(srcManagedObject, forKey: "rubric")
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?,
                     proposedChildIndex index: Int) -> NSDragOperation {
        
        // drags to the root are always acceptable
        let treeNode = item as? NSTreeNode
        if treeNode?.representedObject == nil {
            return .move
        }
        
        // Verify that we are not dragging a parent to one of it's ancestors
        // causes a parent loop where a group of nodes point to each other
        // and disappear from the control
        let draggedNode1 = draggedNode as? NSTreeNode
        let dragged = draggedNode1?.representedObject as! NSManagedObject
        
        let managedObject = treeNode?.representedObject as! NSManagedObject
        if managedObject is EntityRubric {
            return .move
        }
        if category(dragged, isSubCategoryOf: managedObject) {
            return .move
        }
        return .move
    }

    func category(_ cat: NSManagedObject, isSubCategoryOf possibleSub: NSManagedObject) -> Bool {
        // Depends on your interpretation of subCategory ....
        if cat == possibleSub {
            return true
        }
        let possSubParent = possibleSub.value(forKey: "rubric") as? NSManagedObject
        let result = possSubParent is EntityRubric
        return result
    }
    
}
