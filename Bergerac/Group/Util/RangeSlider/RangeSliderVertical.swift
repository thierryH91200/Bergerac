//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by Matt Reagan on 10/29/16.
//  Copyright © 2016 Matt Reagan.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//****************************************************************************//
//****************************************************************************//
/*
 RangeSlider is a general-purpose macOS control which is similar to NSSlider
 except that it allows for the selection of a span or range (it has two control
 points, a start and end, which can both be adjusted).
 */
//****************************************************************************//
//****************************************************************************//


import AppKit


@IBDesignable
final class RangeSliderVertical: RangeSlider {
    

    // MARK: - Public API -
    
    /** Optional action block, called when the control's start or end values change. */
    var onControlChanged: ((RangeSliderVertical) -> Void)?
    
    /** The start of the selected span in the slider. */
    @objc
    var start: Double {
        get {
            return (selection.start * (maxValue - minValue)) + minValue
        }
        
        set {
            let fractionalStart = (newValue - minValue) / (maxValue - minValue)
            selection = SelectionRange(start: fractionalStart, end: selection.end)
            setNeedsDisplay(bounds)
        }
    }
    
    /** The end of the selected span in the slider. */
    @objc
    var end: Double {
        get {
            return (selection.end * (maxValue - minValue)) + minValue
        }
        
        set {
            let fractionalEnd = (newValue - minValue) / (maxValue - minValue)
            selection = SelectionRange(start: selection.start, end: fractionalEnd)
            setNeedsDisplay(bounds)
        }
    }
    
    /** The length of the selected span. Note that by default
     this length is inclusive when snapsToIntegers is true,
     which will be the expected/desired behavior in most such
     configurations. In scenarios where it may be weird to have
     a length of 1.0 when the start and end slider are at an
     identical value, you can disable this by setting
     inclusiveLengthForSnapTo to false. */
    @objc
    var length: Double {
        let fractionalLength = (selection.end - selection.start)
        return (fractionalLength * (maxValue - minValue)) + (snapsToIntegers && inclusiveLengthForSnapTo ? 1.0 : 0.0)
    }
    
    // MARK: - Properties -
    private var selection: SelectionRange = SelectionRange(start: 0.0, end: 1.0) {
        willSet {
            if newValue.start != selection.start {
                self.willChangeValue(forKey: "start")
            }
            
            if newValue.end != selection.end {
                self.willChangeValue(forKey: "end")
            }
            
            if (newValue.end - newValue.start) != (selection.end - selection.start) {
                self.willChangeValue(forKey: "length")
            }
        }
        
        didSet {
            var valuesChanged: Bool = false
            
            if oldValue.start != selection.start {
                self.didChangeValue(forKey: "start")
                valuesChanged = true
            }
            
            if oldValue.end != selection.end {
                self.didChangeValue(forKey: "end")
                valuesChanged = true
            }
            
            if (oldValue.end - oldValue.start) != (selection.end - selection.start) {
                self.didChangeValue(forKey: "length")
            }
            
            if valuesChanged {
                if let block = onControlChanged {
                    block(self)
                }
            }
        }
    }
    
    // MARK: - UI Sizing -
    private var sliderHeight: CGFloat {
        if knobStyle == .square {
            return 8.0
        } else {
            return bounds.width - shadowPadding
        }
        
    }
    
    private var sliderWidth: CGFloat {
        return bounds.width - shadowPadding
    }
    
    private var minSliderY: CGFloat {
        return 0.0
    }
    
    private var maxSliderY: CGFloat {
        return bounds.height - sliderHeight - barTrailingMargin
    }
    
    // MARK: - Event -
    // ok changed
    override func mouseDown(with event: NSEvent) {
        if isEnabled {
            let point = convert(event.locationInWindow, from: nil)
            let startSlider = frameForStartSlider()
            let endSlider = frameForEndSlider()
            
            if startSlider.contains(point) {
                currentSliderDragging = .start
            } else if endSlider.contains(point) {
                currentSliderDragging = .end
            } else {
                if allowClicksOnBarToMoveSliders {
                    let startDist = abs(startSlider.midY - point.y)
                    let endDist = abs(endSlider.midY - point.y)
                    
                    if startDist < endDist {
                        currentSliderDragging = .start
                    } else {
                        currentSliderDragging = .end
                    }
                    
                    updateForClick(atPoint: point)
                } else {
                    currentSliderDragging = nil
                }
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if isEnabled == true {
            let point = convert(event.locationInWindow, from: nil)
            updateForClick(atPoint: point)
        }
    }
    
    // ok changed
    private func updateForClick(atPoint point: CGPoint) {
        if currentSliderDragging != nil {
            var y = Double(point.y / bounds.height)
            y = max(min(1.0, y), 0.0)
            
            if snapsToIntegers {
                let steps = maxValue - minValue
                y = round(y * steps) / steps
            }
            
            if currentSliderDragging! == .start {
                selection = SelectionRange(start: y, end: max(selection.end, y))
            } else {
                selection = SelectionRange(start: min(selection.start, y), end: y)
            }
            
            setNeedsDisplay(bounds)
        }
    }
    
    // MARK: - Utility -
    private func crispLineRect(_ rect: NSRect) -> NSRect {
        /*  Floor the rect values here, rather than use NSIntegralRect etc. */
        var newRect = NSRect(x: floor(rect.origin.x), y: floor(rect.origin.y), width: floor(rect.size.width), height: floor(rect.size.height))
        newRect.origin.x += 0.5
        newRect.origin.y += 0.5
        
        return newRect
    }
    
    // ok changed
    private func frameForStartSlider() -> NSRect {
        
        var y = max(CGFloat(selection.start) * bounds.height - (sliderHeight / 2.0), minSliderY)
        y = min(y, maxSliderY)
        
        return crispLineRect(NSRect(x: (bounds.width - sliderWidth) / 2.0, y: y, width: sliderWidth, height: sliderHeight))
    }
    
    // ok changed
    private func frameForEndSlider() -> NSRect {
        let height = bounds.height
        var y = CGFloat(selection.end) * height
        y -= (sliderHeight / 2.0)
        y = min(y, maxSliderY)
        y = max(y, minSliderY)
        
        return crispLineRect(NSRect(x: (bounds.width - sliderWidth) / 2.0, y: y, width: sliderWidth, height: sliderHeight))
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        
        assert(bounds.height >= (bounds.width * 2), "Range control expects a reasonable width to height ratio, width should be greater than twice the height at least.")
        assert(bounds.height >= (sliderHeight * 2.0), "Width must be able to accommodate two range sliders.")
        assert(bounds.width >= sliderWidth, "Expects minimum height of at least \(sliderHeight)")
    }
    
    // MARK: - Drawing -
    
    // ok changed
    override func draw(_ dirtyRect: NSRect) {
        
        /*  Setup, calculations */
        let width = bounds.width
        let height = bounds.height - barTrailingMargin
        
        let barWidth = round((width - shadowPadding) * (2.0 / 3.0))
        let barX = floor((width - barWidth) / 2.0)
        
        let startSliderFrame = frameForStartSlider()
        let endSliderFrame = frameForEndSlider()
        
        let barRect = crispLineRect(NSRect(x: barX, y: 0, width: barWidth, height: height))
        
        let x = barX
        let y = CGFloat(selection.start) * height
        
        let selectedRect = crispLineRect(NSRect(x: x, y: y, width: barWidth, height: height * CGFloat(selection.end - selection.start)))
        let radius = barWidth / 3.0
        let isSquareSlider = (knobStyle == .square)
        
        /*  Create bezier paths */
        let framePath = NSBezierPath(roundedRect: barRect, xRadius: radius, yRadius: radius)
        let selectedPath = NSBezierPath(roundedRect: selectedRect, xRadius: radius, yRadius: radius)
        
        let startSliderPath = isSquareSlider ? NSBezierPath(roundedRect: startSliderFrame, xRadius: 2.0, yRadius: 2.0) : NSBezierPath(ovalIn: startSliderFrame)
        let endSliderPath = isSquareSlider ? NSBezierPath(roundedRect: endSliderFrame, xRadius: 2.0, yRadius: 2.0) : NSBezierPath(ovalIn: endSliderFrame)
        
        /*  Draw bar background */
        barBackgroundGradient.draw(in: framePath, angle: -gradientDegrees)
        
        /*  Draw bar fill */
        if selectedRect.width > 0.0 {
            if barFillGradient == nil {
                barFillGradient = createBarFillGradientBasedOnCurrentStyle()
            }
            
            if let fillGradient = barFillGradient {
                fillGradient.draw(in: selectedPath, angle: gradientDegrees)
                barFillStrokeColor.setStroke()
                selectedPath.stroke()
            }
        }
        
        barStrokeColor.setStroke()
        framePath.stroke()
        
        /*  Draw slider shadows */
        if let shadow = sliderShadow() {
            NSGraphicsContext.saveGraphicsState()
            shadow.set()
            
            NSColor.white.set()
            startSliderPath.fill()
            endSliderPath.fill()
            NSGraphicsContext.restoreGraphicsState()
        }
        
        /*  Draw slider knobs */
        sliderGradient.draw(in: endSliderPath, angle: gradientDegrees)
        endSliderPath.stroke()
        
        sliderGradient.draw(in: startSliderPath, angle: gradientDegrees)
        startSliderPath.stroke()
    }
}

