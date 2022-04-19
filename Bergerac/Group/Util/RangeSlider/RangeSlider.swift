//
//  RangeSlider.swift
//
//  Created by thierry hentic on 14/04/2019.
//

import AppKit

struct SelectionRange {
    var start: Double
    var end: Double
}

enum DraggedSlider {
    case start
    case end
}

enum RangeSliderColorStyle {
    case yellow
    case aqua
}

enum RangeSliderKnobStyle {
    case square
    case circular
}

class RangeSlider: NSView {
    
    let gradientDegrees: CGFloat = -90.0
    let shadowPadding: CGFloat = 4.0
    
    let barTrailingMargin: CGFloat = 1.0
    let disabledControlDimmingRatio: CGFloat = 0.65
    
    // MARK: - Public API -
    /** Whether the control is enabled. By default, if set to false, the control will
     render itself dimmed and ignores user interaction. */
    @IBInspectable
    var isEnabled: Bool = true {
        didSet {
            recreateBarFillGradient()
            setNeedsDisplay(bounds)
        }
    }
    
    /** The minimum value of the slider. */
    @IBInspectable
    var minValue: Double = 0.0 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    /** The maximum value of the slider. */
    @IBInspectable
    var maxValue: Double = 1.0 {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    /** Defaults is false (off). If set to true, the slider
     will snap to whole integer values for both sliders. */
    @IBInspectable
    var snapsToIntegers: Bool = false
    
    /** Defaults to true, and makes the length property
     inclusive when snapsToIntegers is enabled. */
    var inclusiveLengthForSnapTo: Bool = true
    
    /** Defaults to true, allows clicks off of the slider knobs
     to reposition the bars. */
    var allowClicksOnBarToMoveSliders: Bool = true
    
    /** The color style of the slider. */
    var colorStyle: RangeSliderColorStyle = .aqua {
        didSet {
            recreateBarFillGradient()
            setNeedsDisplay(bounds)
        }
    }
    
    /** The shape style of the slider knobs. Defaults to square. */
    var knobStyle: RangeSliderKnobStyle = .square {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    
    // MARK: - Appearance -
    lazy var sliderGradient: NSGradient = {
        let backgroundStart = NSColor(white: 0.92, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.80, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    lazy var barBackgroundGradient: NSGradient = {
        let backgroundStart = NSColor(white: 0.85, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.70, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    var barFillGradient: NSGradient?
    
    private func recreateBarFillGradient() {
        barFillGradient = createBarFillGradientBasedOnCurrentStyle()
    }
    
    func createBarFillGradientBasedOnCurrentStyle() -> NSGradient {
        var fillStart: NSColor?
        var fillEnd: NSColor?
        
        if colorStyle == .yellow {
            fillStart = NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
            fillEnd = NSColor(red: 1.0, green: 196 / 255.0, blue: 0.0, alpha: 1.0)
        } else {
            fillStart = NSColor(red: 76 / 255.0, green: 187 / 255.0, blue: 251 / 255.0, alpha: 1.0)
            fillEnd = NSColor(red: 20 / 255.0, green: 133 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        }
        
        if isEnabled == false {
            fillStart = fillStart?.colorByDesaturating(disabledControlDimmingRatio).withAlphaComponent(disabledControlDimmingRatio)
            fillEnd = fillEnd?.colorByDesaturating(disabledControlDimmingRatio).withAlphaComponent(disabledControlDimmingRatio)
        }
        
        let barFillGradient = NSGradient(starting: fillStart!, ending: fillEnd!)
        assert(barFillGradient != nil, "Couldn't generate gradient.")
        
        return barFillGradient!
    }
    
    var barStrokeColor: NSColor {
        return NSColor(white: 0.0, alpha: 0.25)
    }
    
    var barFillStrokeColor: NSColor {
        var colorForStyle: NSColor
        
        if colorStyle == .yellow {
            colorForStyle = NSColor(red: 1.0, green: 170 / 255.0, blue: 16 / 255.0, alpha: 0.70)
        } else {
            colorForStyle = NSColor(red: 12 / 255.0, green: 118 / 255.0, blue: 227 / 255.0, alpha: 0.70)
        }
        
        if !isEnabled {
            colorForStyle = colorForStyle.colorByDesaturating(disabledControlDimmingRatio)
        }
        return colorForStyle
        
    }
    
    private var _sliderShadow: NSShadow?
    func sliderShadow() -> NSShadow? {
        if _sliderShadow == nil {
            let shadowOffset = NSSize(width: 2.0, height: -2.0)
            let shadowBlurRadius: CGFloat = 2.0
            let shadowColor = NSColor(white: 0.0, alpha: 0.12)
            
            let shadow = NSShadow()
            shadow.shadowOffset = shadowOffset
            shadow.shadowBlurRadius = shadowBlurRadius
            shadow.shadowColor = shadowColor
            
            _sliderShadow = shadow
        }
        
        return _sliderShadow
    }
    
    var currentSliderDragging: DraggedSlider?
    
}
