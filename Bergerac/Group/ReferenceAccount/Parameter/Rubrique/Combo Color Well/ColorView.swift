//
//  ColorView.swift
//  ComboColorWell
//
//  Created by thierry hentic on 28/11/2019.
//  Copyright © 2019 Cool Runnings. All rights reserved.
//

import AppKit

/**
 A view to represent a color in a grid.
 */
class ColorView: NSView {
    
    // MARK: - public vars
    
    let color: NSColor
    
    var selected = false {
        didSet {
            needsDisplay = true
        }
    }

    // MARK: - private vars
    
    private weak var colorGridView: ColorGridView?

    // MARK: - init & overrided functions
    
    init(color: NSColor, in colorGridView: ColorGridView) {
        self.color = color
        self.colorGridView = colorGridView
        super.init(frame: .zero) // NSRect(origin: NSPoint(x: 0, y: 0), size: NSSize(width: 50, height: 30)))
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        if color == .clear {
            NSColor.white.setFill()
        } else {
            color.setFill()
        }
        
        context.fill(dirtyRect)
        
        if color == .clear {
            NSColor.red.setStroke()
            context.beginPath()
            context.move(to: dirtyRect.origin)
            context.addLine(to: CGPoint(x: dirtyRect.width, y: dirtyRect.height))
            context.strokePath()
        }
        
        if selected {
            NSColor.white.setStroke()
        } else {
            NSColor.gray.withAlphaComponent(0.5).setStroke()
        }

        context.stroke(dirtyRect, width: selected ? 2.0 : 1.0)
    }
    
    override func mouseDown(with event: NSEvent) {
        selected = true
    }

    override func mouseDragged(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        selected = bounds.contains(point)
    }

    override func mouseUp(with event: NSEvent) {
        if selected {
            colorGridView?.colorSelected(color)
        }
    }

}
