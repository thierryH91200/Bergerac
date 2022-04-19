//
//  ComboColorWell.swift
//  Tasty Testy
//
//  Created by Ernesto Giannotta on 16-08-18.
//  Copyright © 2018 Apimac. All rights reserved.
//

import AppKit

/**
 A control to pick a color.
 It has the look & feel of the color control of Apple apps like Pages, Numbers etc.
 */
final class ComboColorWell: NSControl {
    
    // MARK: - public vars
    
    /**
     The color currently represented by the control.
     */
    @IBInspectable var color: NSColor {
        get {
            return comboColorWellCell.color
        }
        set {
            comboColorWellCell.color = newValue
        }
    }
    
    /**
     Set this to false if you don't want the popover to show the clear color in the grid.
     */
    @IBInspectable var allowClearColor: Bool {
        get {
            return comboColorWellCell.allowClearColor
        }
        set {
            comboColorWellCell.allowClearColor = newValue
        }
    }
    
    // MARK: - private vars
    
    /**
     The action cell that will do the heavy lifting for the us.
     */
    private var comboColorWellCell: ComboColorWellCell {
        guard let cell = cell as? ComboColorWellCell else { fatalError("ComboColorWellCell not valid") }
        return cell
    }
    
    // MARK: - Overridden functions
    override func resignFirstResponder() -> Bool {
        comboColorWellCell.state = .off
        return super.resignFirstResponder()
    }
    
    // MARK: - init & private functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        doInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInit()
    }
    
    private func doInit() {
        cell = ComboColorWellCell()
    }
    
}

extension ComboColorWell: NSColorChanging {
    func changeColor(_ sender: NSColorPanel?) {
        if let sender = sender {
            comboColorWellCell.colorAction(sender)
        }
    }
}


