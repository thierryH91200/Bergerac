//
//  ColorGridView.swift
//  ComboColorWell
//
//  Created by thierry hentic on 28/11/2019.
//  Copyright © 2019 Cool Runnings. All rights reserved.
//

import AppKit



/// A grid of selectable color view objects.
class ColorGridView: NSGridView {
    // MARK: - public vars

    weak var delegate: ColorGridViewDelegate?
    
    /**
     An array of NSColor arrays, meant to be presented as columns in the grid.
     */
    var colorArrays: [[NSColor]] = [[NSColor(red: 72, green: 179, blue: 255),
                                NSColor(red: 18, green: 141, blue: 254),
                                NSColor(red: 12, green: 96, blue: 172),
                                NSColor(red: 7, green: 59, blue: 108),
                                .white],
                               [NSColor(red: 102, green: 255, blue: 228),
                                NSColor(red: 36, green: 228, blue: 196),
                                NSColor(red: 20, green: 154, blue: 140),
                                NSColor(red: 14, green: 105, blue: 99),
                                NSColor(red: 205, green: 203, blue: 203)],
                               [NSColor(red: 122, green: 255, blue: 62),
                                NSColor(red: 83, green: 212, blue: 42),
                                NSColor(red: 32, green: 166, blue: 3),
                                NSColor(red: 13, green: 97, blue: 2),
                                NSColor(red: 128, green: 128, blue: 128)],
                               [NSColor(red: 255, green: 255, blue: 85),
                                NSColor(red: 249, green: 222, blue: 40),
                                NSColor(red: 245, green: 173, blue: 9),
                                NSColor(red: 253, green: 128, blue: 8),
                                NSColor(red: 76, green: 76, blue: 76)],
                               [NSColor(red: 253, green: 129, blue: 122),
                                NSColor(red: 251, green: 76, blue: 62),
                                NSColor(red: 230, green: 0, blue: 14),
                                NSColor(red: 164, green: 0, blue: 2),
                                .black],
                               [NSColor(red: 252, green: 116, blue: 185),
                                NSColor(red: 232, green: 67, blue: 151),
                                NSColor(red: 189, green: 14, blue: 104),
                                NSColor(red: 133, green: 1, blue: 76),
                                .clear]] {
        didSet {
            setupGrid()
        }
    }
    
    /**
     Set this to false if you don't want the popover to show the clear color in the grid.
     */
    var allowClearColor = true {
        didSet {
            if let colorView = colorView(for: .clear) {
                colorView.isHidden = !allowClearColor
            }
        }
    }
    
    // MARK: - public functions

    /**
     Try to select the element in the grid that represents the passed color.
     */
    @discardableResult func selectColor(_ color: NSColor) -> Bool {
        if let colorView = colorView(for: color) {
            colorView.selected = true
            return true
        }
        return false
    }

    // MARK: - init & overrided functions
    
    init() {
        super.init(frame: .zero)
        
        rowSpacing = 1.0
        columnSpacing = 1.0
        
        setupGrid()
    }
    
    convenience init(in view: NSView) {
        self.init()
        
        // make sure to disable autoresizing mask translations
        translatesAutoresizingMaskIntoConstraints = false
        
        // add the grid view programmatically (macOS 10.12 doesn't play well with IB instantiated grids)
        view.addSubview(self)
        
        // hook the borders of the grid to the parent view
        view.addConstraints([NSLayoutConstraint(equalAttribute: .top, for: (self, view)),
                             NSLayoutConstraint(equalAttribute: .bottom, for: (self, view)),
                             NSLayoutConstraint(equalAttribute: .trailing, for: (self, view)),
                             NSLayoutConstraint(equalAttribute: .leading, for: (self, view))])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private functions

    /**
     Build the colors grid here.
     */
    private func setupGrid() {
        // start with an empty grid
        (0..<numberOfRows).forEach { removeRow(at: $0) }
        
        // get colors as arrays of ColorView objects
        let views = colorArrays.map {
            return $0.map { ColorView(color: $0, in: self) }
        }
        
        // Treat each array in views as a column of the grid
        views.forEach { addColumn(with: $0) }
        
        setPadding(5.0)
        
        // set grid elements size and placement
        (0..<numberOfColumns).forEach {
            let column = self.column(at: $0)
            column.width = 35
            column.xPlacement = .fill
        }
        
        (0..<numberOfRows).forEach {
            let row = self.row(at: $0)
            row.height = 20
            row.yPlacement = .fill
        }

    }
    
    /**
     Set top, bottom, left and right margins as padding.
     */
    private func setPadding(_ padding: CGFloat) {
        guard numberOfRows > 0 else { return }
        
        row(at: 0).topPadding = padding
        row(at: numberOfRows - 1).bottomPadding = padding
        
        guard numberOfColumns > 0 else { return }
        
        let firstCol = column(at: 0)
        let lastCol = column(at: numberOfColumns - 1)
        
        firstCol.leadingPadding = padding
        lastCol.trailingPadding = padding
    }
    
    /**
     Try to find the element in the grid that represents the passed color.
     */
    private func colorView(for color: NSColor) -> ColorView? {
        for (columnIndex, colorArray) in colorArrays.enumerated() {
            if let rowIndex = colorArray.firstIndex(of: color) {
                return column(at: columnIndex).cell(at: rowIndex).contentView as? ColorView
            }
        }
        return nil
    }
    
    /// User has selected a color, tell it to the delegate.
    func colorSelected(_ color: NSColor) {
        delegate?.colorGridView(self, didChoose: color)
    }
    
}

extension NSColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(calibratedRed: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
    }
}


