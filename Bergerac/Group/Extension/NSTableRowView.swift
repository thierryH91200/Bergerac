    //
    //  NSTableRowView.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 03/10/2021.
    //

import AppKit



    // MARK: - MyNSTableRowView
class MyNSTableRowView: NSTableRowView {
    
    init()
    {
        super.init(frame: .zero)
        isTargetForDropOperation = false
        draggingDestinationFeedbackStyle = .none
        selectionHighlightStyle = .none
    }
    
    required init?(coder decoder: NSCoder) { nil }
    
    override func drawBackground(in dirtyRect: NSRect) {} // this avoids a visual bug
    override func drawSeparator(in dirtyRect: NSRect) {}
    
    struct SharedColors {
        static let backgroundColor = NSColor(red: 0.76, green: 0.82, blue: 0.92, alpha: 1)
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        super.drawSelection(in: dirtyRect)
        
        if isSelected == false {
            NSColor.selectedControlColor.set()
            __NSRectFill(dirtyRect)
        } else {
            SharedColors.backgroundColor.set()
            __NSRectFill(dirtyRect)
        }
    }
}


    // MARK: - NSTableRowView
//class tableRowView: NSTableRowView {
//
//    override func drawSelection(in dirtyRect: NSRect) {
//        if self.selectionHighlightStyle != .none {
//            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
//            NSColor(calibratedWhite: 0.65, alpha: 1).setStroke()
//            NSColor(calibratedWhite: 0.82, alpha: 1).setFill()
//            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 3, yRadius: 3)
//            selectionPath.fill()
//            selectionPath.stroke()
//        }
//    }
//
//    override var interiorBackgroundStyle:NSView.BackgroundStyle  {
//        get
//        {
//            if self.isSelected == true {
//                return NSView.BackgroundStyle.emphasized
//            }
//            else {
//                return NSView.BackgroundStyle.normal
//            }
//        }
//    }
//}

    // MARK: - MenuTableRowView
//class MenuTableRowView: NSTableRowView {
//
//    override func drawSelection(in dirtyRect: NSRect) {
//        super.drawSelection(in: dirtyRect)
//
//        if self.selectionHighlightStyle != .none {
//
//            if let color = NSColor.init(named: NSColor.Name("menu_table_selection_color")) {
//                color.setFill()
//            }
//
//            let selectionRect = NSInsetRect(self.bounds, 1.5, 1.5)
//            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
//            selectionPath.fill()
//        }
//    }
//}
