import Cocoa

extension NSWindow {
    // Adapted from http://stackoverflow.com/a/36006764/299262
//    func shake(numberOfShakes: Int = 3, durationOfShake: Double = 0.5, vigorOfShake: CGFloat = 0.03) {
//        let frame = self.frame
//        let shakeAnimation  = CAKeyframeAnimation()
//        
//        let shakePath = CGMutablePath()
//        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))
//        for _ in 0...numberOfShakes-1 {
//            shakePath.addLine(to: CGPoint(x: NSMinX(frame) - frame.size.width * vigorOfShake, y: NSMinY(frame)))
//            shakePath.addLine(to: CGPoint(x: NSMinX(frame) + frame.size.width * vigorOfShake, y: NSMinY(frame)))
//        }
//        
//        shakePath.closeSubpath();
//        shakeAnimation.path = shakePath
//        shakeAnimation.duration = durationOfShake
//        
//        self.animations = [NSAnimatablePropertyKey( "frameOrigin"): shakeAnimation]
//        self.animator().setFrameOrigin(self.frame.origin)
//    }
    
    func toolbarHeight() -> CGFloat {
        var toolbar: NSToolbar?
        var toolbarHeight = CGFloat(0.0)
        var windowFrame: NSRect
        
        toolbar = self.toolbar
        
        if let toolbar = toolbar {
            if toolbar.isVisible {
                windowFrame = NSWindow.contentRect(forFrameRect: self.frame, styleMask: self.styleMask)
                toolbarHeight = windowFrame.height - (self.contentView?.frame.height)!
            }
        }
        return toolbarHeight
    }

}

extension NSTextField {
    
    func shake(withCompletion block: (() -> Void)? = nil) {
        wantsLayer = true
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, -10, 10, 0]
        let times: [NSNumber] = [0, NSNumber(value: 1 / 6.0), NSNumber(value: 2 / 6.0), NSNumber(value: 3 / 6.0), NSNumber(value: 4 / 6.0), NSNumber(value: 5 / 6.0), 1]
        animation.keyTimes = times
        animation.duration = 0.6
        animation.isAdditive = true
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            if block != nil {
                block?()
            }
        })
        layer?.add(animation, forKey: "xuikit_shake")
        CATransaction.commit()
    }
}





