//
//  MouseTracker.swift
//  ComboColorWell
//
//  Created by thierry hentic on 28/11/2019.
//  Copyright © 2019 Cool Runnings. All rights reserved.
//

import Cocoa

/**
 An NSResponder subclass to handle mouse events.
 */
class MouseTracker: NSResponder {
    let mouseEnteredHandler: (_ : NSEvent) -> ()
    let mouseExitedHandler: (_ : NSEvent) -> ()
    let mouseMovedHandler: ((_ : NSEvent) -> ())?
    
    /**
     The designated initializer.
     Requires handlers for the entered and exited events.
     Moved event handler is optional.
     */
    init(mouseEntered enteredHandler: @escaping (_ event: NSEvent) -> (),
         mouseExited exitedHandler: @escaping (_ event: NSEvent) -> (),
         mouseMoved movedHandler: ((_ event: NSEvent) -> ())? = nil) {
        mouseEnteredHandler = enteredHandler
        mouseExitedHandler = exitedHandler
        mouseMovedHandler = movedHandler
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseEnteredHandler(event)
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseExitedHandler(event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        mouseMovedHandler?(event)
    }
    
}

