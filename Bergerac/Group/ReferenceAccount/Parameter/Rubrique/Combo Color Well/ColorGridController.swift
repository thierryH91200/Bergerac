//
//  ColorGridController.swift
//  ComboColorWell
//
//  Created by thierry hentic on 28/11/2019.
//  Copyright © 2019 Cool Runnings. All rights reserved.
//

import AppKit
/**
 A controller for a grid view to show and select colors.
 */
class ColorGridController: NSViewController {
    
    // MARK: - public vars
    
    /**
     The color we want to show as selected in the grid.
     */
    var color = NSColor.black {
        didSet {
            // try to select the color in the grid view.
            (view as? ColorGridView)?.selectColor(color)
        }
    }
    
    /**
     Set this to false if you don't want the popover to show the clear color in the grid.
     */
    var allowClearColor = true {
        didSet {
            // propagate setting to the grid view.
            (view as? ColorGridView)?.allowClearColor = allowClearColor
        }
    }

    // MARK: - private vars
    
    /**
     The target that will receive the action message, only it neither is nil, when color has been chosen.
     */
    private weak var target: AnyObject?
    /**
     The action that will be sent to the target, only it neither is nil, when color has been chosen.
     */
    private var action: Selector?
    /**
     The delegate that will be notified when color has been chosen.
     Deprecated approach.
     */
    private weak var delegate: ColorGridViewDelegate?
    
    // MARK: - init & overrided functions
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(delegate: ColorGridViewDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    convenience init(color: NSColor, target: AnyObject, action: Selector, allowClearColor: Bool = true) {
        self.init()
        self.color = color
        self.target = target
        self.action = action
        self.allowClearColor = allowClearColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // create here our color grid
        let colorGrid = ColorGridView()
        view = colorGrid
        colorGrid.delegate = self
        colorGrid.allowClearColor = allowClearColor
        colorGrid.selectColor(color)
    }

}

// conform to the ColorGridViewDelegate protocol.
extension ColorGridController: ColorGridViewDelegate {
    /**
     Handle the color choice.
     */
    func colorGridView(_ colorGridView: ColorGridView, didChoose color: NSColor) {
        self.color = color
        view.window?.performClose(self)
        if let target = target,
            let action = action {
            let _ = target.perform(action, with: self)
        }
        delegate?.colorGridView(colorGridView, didChoose: color)
    }
}

/**
 Add ColorProvider conformance to NSPanel
 */
extension ColorGridController: ColorProvider {}

/**
 The protocol for a delegate to handle color choice.
 */
protocol ColorGridViewDelegate: AnyObject {
    func colorGridView(_ colorGridView: ColorGridView, didChoose color: NSColor)
}


// MARK: - Protocols & Extensions

/**
 handy protocol for classes that have a color var
*/
@objc protocol ColorProvider {
    var color: NSColor { get set }
}

/**
 Add ColorProvider conformance to NSPanel
 */
extension NSColorPanel: ColorProvider {}

extension NSLayoutConstraint {
    public convenience init(equalAttribute: NSLayoutConstraint.Attribute,
                            for items: (NSView, NSView?),
                            multiplier: CGFloat = 1.0,
                            constant: CGFloat = 0.0) {
        
        self.init(item: items.0,
                  attribute: equalAttribute,
                  relatedBy: .equal,
                  toItem: items.1,
                  attribute: (items.1 != nil) ?
                    equalAttribute :
                    .notAnAttribute,
                  multiplier: multiplier,
                  constant: constant)
    }
}

