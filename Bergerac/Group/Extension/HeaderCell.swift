import AppKit



// MARK: - KSHeaderCellView
final class KSHeaderCellView: NSTableCellView {
    
    var fillColor = NSColor.orange
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bPath = NSBezierPath(rect: dirtyRect)
        fillColor.set()
        bPath.fill()
    }
}

// MARK: - CrossHatchView
final class CrossHatchView: CategoryCellView {
    
    override func draw(_ rect: CGRect) {
        
        let radius : CGFloat  = 5
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
        //            path.addClip()
        
        let pathBounds = path.bounds
        path.removeAllPoints()
        let p1 = CGPoint(x:pathBounds.maxX, y:0)
        let p2 = CGPoint(x:0, y:pathBounds.maxX)
        path.move(to: p1)
        path.line(to: p2)
        path.lineWidth = bounds.width * 2
        
        let dashes:[CGFloat] = [0.5, 7.0]
        path.setLineDash(dashes, count: 2, phase: 0.0)
        NSColor.lightGray.withAlphaComponent(0.8).set()
        path.stroke()
    }    
}



