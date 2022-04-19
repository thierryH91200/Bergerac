import AppKit

final class KSWhiteBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSGraphicsContext.saveGraphicsState()
        NSColor(calibratedWhite: 0.85, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: bounds, xRadius: 8.0, yRadius: 8.0).fill()
        NSGraphicsContext.restoreGraphicsState()
    }
}

