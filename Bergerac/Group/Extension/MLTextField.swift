//
//  MLCalendarCell.swift
//  ModernLookOSXSampleSwift
//
//  Created by thierry hentic on 21/04/2019.
//  Copyright © 2019 thierry hentic. All rights reserved.
//

import AppKit

protocol TextFieldDelegate: AnyObject {
    func textFieldDidBecomeFirstResponder(_ textField: MLTextField)
    func textFieldDidResignFirstResponder(_ textField: MLTextField)
}

class MLTextField: NSTextField {
    
    weak var firstResponderDelegate: TextFieldDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let fnt: NSFont? = font
        let regular = NSFont.systemFont(ofSize: 0)
        var restoreFont = false
        if regular != font {
            restoreFont = true
        }
        commonInit()
        if restoreFont {
            font = fnt
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    func commonInit() {
        font = NSFont(name: "Helvetica Neue Thin", size: 16.0)
        isBordered = false
        backgroundColor = .clear
        focusRingType = .none
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSGraphicsContext.saveGraphicsState()
        
        let bounds = self.bounds
        textColor?.set()
        
        let bottomLine = NSBezierPath()
        var p = NSPoint.zero //bounds.origin;
        p.y = bounds.size.height
        bottomLine.move(to: p)
        p.x += bounds.size.width
        bottomLine.line(to: p)
        bottomLine.lineWidth = 2
        bottomLine.stroke()
        
        let heightLine = NSBezierPath()
        var p2 = NSPoint.zero
        heightLine.move(to: p2)
        p2.y = bounds.size.height
        heightLine.line(to: p2)
        heightLine.lineWidth = 2
        heightLine.stroke()
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
    private var isFocused = false {
           didSet {
               if isFocused {
                   firstResponderDelegate?.textFieldDidBecomeFirstResponder(self)
               } else {
                   firstResponderDelegate?.textFieldDidResignFirstResponder(self)
               }
           }
       }

       override func resignFirstResponder() -> Bool {
           let willResign = super.resignFirstResponder()
           
           if willResign, let _ = currentEditor() {
               isFocused = true
           }
           return willResign
       }
     
    
}
