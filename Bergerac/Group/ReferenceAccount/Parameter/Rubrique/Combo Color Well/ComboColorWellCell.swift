//
//  ComboColorWellCell.swift
//  ComboColorWell
//
//  Created by thierry hentic on 28/11/2019.
//  Copyright © 2019 Cool Runnings. All rights reserved.
//

import Cocoa

/**
 The action cell that will do the heavy lifting for the ComboColorWell control.
 */
class ComboColorWellCell: NSActionCell {
    /**
     Enumerate sensible areas of the control cell.
     */
    enum ControlArea {
        case nothing
        case color
        case button
    }
    /**
     Enumerate possible mouse states.
     */
    enum MouseState {
        case outside
        case over(ControlArea)
        case down(ControlArea)
        case up(ControlArea)
    }
    
    // MARK: - public vars
    
    /**
     The color we're representing.
     */
    var color = NSColor.black {
        didSet {
            controlView?.needsDisplay = true
        }
    }
    /**
     Set this to false if you don't want the popover to show the clear color in the grid.
     */
    var allowClearColor = true
    
    // MARK: - public functions
    
    func mouseEntered(with event: NSEvent) {
        if isEnabled {
            mouseMoved(with: event)
        }
    }
    
    func mouseExited(with event: NSEvent) {
        if isEnabled {
            mouseState = .outside
        }
    }
    
    func mouseMoved(with event: NSEvent) {
        if isEnabled {
            mouseState = .over(controlArea(for: event))
        }
    }
    
    /**
     The standard objc action function to handle color change messages from the Color panel and Color popover.
     */
    @objc func colorAction(_ sender: ColorProvider) {
        action(for: sender.color)
    }
    
    /**
     The function that will propagate the control action message to the control target.
     */
    private func action(for color: NSColor) {
        self.color = color
        if let control = controlView as? NSControl {
            control.sendAction(control.action, to: control.target)
        }
    }
    
    // MARK: - private vars
    
    /**
     A NSResponder to handle mouse events.
     */
    private lazy var mouseTracker = {
        return MouseTracker(mouseEntered: { self.mouseEntered(with: $0) },
                            mouseExited: { self.mouseExited(with: $0) },
                            mouseMoved: { self.mouseMoved(with: $0) })
    }()
    
    /**
     The current mouse state.
     */
    private var mouseState = MouseState.outside {
        didSet {
            if mouseState != oldValue {
                handleMouseState(mouseState)
                controlView?.needsDisplay = true
            }
        }
    }
    
    /**
     Keep track of the colors popover visibility.
     */
    var colorsPopoverVisible = false
    
    /**
     How much we want to inset the images (down arrow and color wheel) in the control.
     */
    private let imageInset = CGFloat(3.5)
    
    // MARK: - overrided vars
    
    override var controlView: NSView? {
        didSet {
            // add a tracking area to let our mouse tracker handle significant events
            controlView?.addTrackingArea(NSTrackingArea(rect: .zero,
                                                        options: [.mouseEnteredAndExited,
                                                                  .mouseMoved,
                                                                  .activeInKeyWindow,
                                                                  .inVisibleRect],
                                                        owner: mouseTracker,
                                                        userInfo: nil))
        }
    }
    
    override var state: NSControl.StateValue {
        didSet {
            // handle the new state
            handleStateChange()
        }
    }
    
    // MARK: - overrided functions
    
    override func setNextState() {
        // disable next state default setting, called mainly by the default cell mouse tracking
        return
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        // helper functions
        
        /**
         Fill the passed path with the passed color.
         */
        func fill(path: NSBezierPath, withColor color: NSColor = .controlColor) {
            color.setFill()
            path.fill()
        }
        
        /**
         Fill the passed path with the passed gradient.
         */
        func fill(path: NSBezierPath, withGradient gradient: NSGradient) {
            gradient.draw(in: path, angle: 90.0)
        }
        
        // hard coded colors and gradients
        let buttonGradient: NSGradient = {
            NSGradient(starting: NSColor(red: 17, green: 103, blue: 255),
                       ending: NSColor(red: 95, green: 165, blue: 255))!
        }()
        
        NSColor.black.withAlphaComponent(0.25).setStroke()
        
        // give some space to the control rect for anti aliasing
        let smoothRect = cellFrame.insetBy(dx: 0.5, dy: 0.5)
        
        // the bezier path defining the control
        let path = NSBezierPath(roundedRect: smoothRect, xRadius: 6.0, yRadius: 6.0)
        path.lineWidth = 0.0
        
        if state == .on {
            // on state always draws a selected button
            fill(path: path, withGradient: buttonGradient)
        } else {
            switch mouseState {
            case .outside,
                 .up:
                fill(path: path)
            case let .over(controlArea):
                switch controlArea {
                case .button:
                    // mouse over button draws a darker background
                    fill(path: path, withColor: NSColor.lightGray.withAlphaComponent(0.25))
                default:
                    fill(path: path)
                }
            case let .down(controlArea):
                switch controlArea {
                case .button:
                    // clicked button draws selected
                    fill(path: path, withGradient: buttonGradient)
                default:
                    fill(path: path)
                }
            }
        }
        let rectIm = buttonArea(withFrame: cellFrame, smoothed: true)
        #imageLiteral(resourceName: "ColorWheel").draw(in: rectIm.insetBy(dx: imageInset, dy: imageInset))
        
        // clip to fill the color area
        NSBezierPath.clip(colorArea(withFrame: cellFrame))
        
        if color == .clear {
            // want a diagonal black & white split
            // start filling all white
            fill(path: path, withColor: .white)
            // get the color area
            let area = colorArea(withFrame: cellFrame)
            // get an empty bezier path to draw the black portion
            let blackPath = NSBezierPath()
            // get the origin point of the color area
            var point = area.origin
            // set it the starting point of the black path
            blackPath.move(to: point)
            // draw a line to opposite diagonal
            point = NSPoint(x: area.width, y: area.height)
            blackPath.line(to: point)
            // draw a line back to origin x
            point.x = area.origin.x
            blackPath.line(to: point)
            // close the triangle
            blackPath.close()
            // add clip with the control shape
            path.addClip()
            // finally draw the black portion
            fill(path: blackPath, withColor: .black)
        } else {
            fill(path: path, withColor: color)
        }
        
        // reset the clipping area
        path.setClip()
        // draw the control border
        path.stroke()
        
        if !isEnabled {
            fill(path: path, withColor: NSColor(calibratedWhite: 1.0, alpha: 0.25))
        }
        
        switch mouseState {
        case let .over(controlArea),
             let .down(controlArea):
            switch controlArea {
            case .color:
                #imageLiteral(resourceName: "CircledDownArrow").draw(in: popoverButtonArea(withFrame: cellFrame, smoothed: true))
            default:
                break
            }
        default:
            break
        }
        
    }
    
    override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        switch controlArea(for: startPoint, in: controlView) {
        case .color:
            mouseState = .down(.color)
        case .button:
            mouseState = .down(.button)
        default:
            mouseState = .outside
        }
        return true
    }
    
    override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
        if !flag {
            mouseState = .outside
            return
        }
        switch controlArea(for: stopPoint, in: controlView) {
        case .color:
            mouseState = .up(.color)
        case .button:
            mouseState = .up(.button)
        default:
            mouseState = .up(.nothing)
        }
    }
    
    override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        mouseState = .down(controlArea(for: currentPoint, in: controlView))
        
        return true
    }
    
    // MARK: - private functions
    
    /**
     Handle mpuse state here, currently we're only interested in mouse ups.
     */
    private func handleMouseState(_ state: MouseState) {
        switch state {
        case let .up(controlArea):
            handleMouseUp(in: controlArea)
            mouseState = .over(controlArea)
        default:
            break
        }
    }
    
    /**
     Handle mouse up clicks here.
     */
    private func handleMouseUp(in controlArea: ControlArea) {
        switch controlArea {
        case .button:
            // toggle on and of state
            state = (state == .on ? .off : .on)
        case .color:
            // switch state off
            state = .off
            if colorsPopoverVisible {
                // popover already visible, just bail out
                return
            }
            // we need the control view to show the popove relative to it
            guard let view = controlView else { break }
            // create a popover
            let popover = NSPopover()
            popover.behavior = .semitransient
            // make ourself its delegate
            popover.delegate = self
            // create a Color grid and set it as the popover content
            popover.contentViewController = ColorGridController(color: color,
                                                                target: self,
                                                                action: #selector(colorAction(_:)),
                                                                allowClearColor: allowClearColor)
            // show the popover
            popover.show(relativeTo: popoverButtonArea(withFrame: view.bounds), of: view, preferredEdge: .minY)
            // update the visible flag
            colorsPopoverVisible = true
        default:
            mouseState = .over(controlArea)
        }
    }
    
    /**
     Handle state change here.
     */
    private func handleStateChange() {
        let colorPanel = NSColorPanel.shared
        switch state {
        case .off:
            if colorPanel.isVisible, colorPanel.delegate === self {
                colorPanel.delegate = nil
            }
        case .on:
            if let window = controlView?.window, window.makeFirstResponder(controlView) {
                colorPanel.delegate = self
                colorPanel.showsAlpha = allowClearColor
                colorPanel.color = color
                colorPanel.orderFront(self)
            }
        default:
            break
        }
    }
    
    /**
     Get the rect of the control that displays the selected color.
     */
    private func colorArea(withFrame cellFrame: NSRect, smoothed: Bool = false) -> NSRect {
        var rect = smoothed ?cellFrame.insetBy(dx: 0.5, dy: 0.5) : cellFrame
        rect.size.width -= rect.size.height
        return rect
    }
    
    /**
     Get the rect of the control that displays the color panel button.
     */
    private func buttonArea(withFrame cellFrame: NSRect, smoothed: Bool = false) -> NSRect {
        var rect = smoothed ? cellFrame.insetBy(dx: 0.5, dy: 0.5) : cellFrame
        rect.origin.x += (rect.width - rect.height)
        rect.size.width = rect.height
        return rect
    }
    
    /**
     Get the rect of the control where a down arrow button should be drawn.
     */
    private func popoverButtonArea(withFrame cellFrame: NSRect, smoothed: Bool = false) -> NSRect {
        let buttonSize = CGFloat(15.0)
        let rect = colorArea(withFrame: cellFrame, smoothed: smoothed)
        return NSRect(x: rect.width - (buttonSize + imageInset),
                      y: ceil((rect.height - buttonSize) / 2),
                      width: buttonSize, height: buttonSize)
    }
    
    /**
     Get the area of the control where a mouse event has occurred.
     */
    private func controlArea(for event: NSEvent) -> ControlArea {
        guard let controlView = controlView else { return .nothing }
        return controlArea(for: controlView.convert(event.locationInWindow, from: nil), in: controlView)
    }
    
    /**
     Get the area of the control where a point lies.
     */
    private func controlArea(for point: NSPoint, in controlView: NSView) -> ControlArea {
        if colorArea(withFrame: controlView.bounds).contains(point) {
            return .color
        } else if buttonArea(withFrame: controlView.bounds).contains(point) {
            return .button
        } else {
            return .nothing
        }
    }
    
}

// handle Color panel delegate events here.
extension ComboColorWellCell: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        state = .off
        controlView?.needsDisplay = true
    }
}

// handle Color popover delegate events here.
extension ComboColorWellCell: NSPopoverDelegate {
    func popoverWillClose(_ notification: Notification) {
        colorsPopoverVisible = false
    }
}


/**
 Add equatable conformance to MouseState enum
 */
extension ComboColorWellCell.MouseState: Equatable {
    static func == (lhs: ComboColorWellCell.MouseState, rhs: ComboColorWellCell.MouseState) -> Bool {
        switch lhs {
        case .outside:
            switch rhs {
            case .outside:
                return true
            default:
                return false
            }
        case let .over(leftArea):
            switch rhs {
            case let .over(rightArea):
                return leftArea == rightArea
            default:
                return false
            }
        case let .down(leftArea):
            switch rhs {
            case let .down(rightArea):
                return leftArea == rightArea
            default:
                return false
            }
        case let .up(leftArea):
            switch rhs {
            case let .up(rightArea):
                return leftArea == rightArea
            default:
                return false
            }
        }
    }
}


