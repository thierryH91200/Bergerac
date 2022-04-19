    //
    //  AccountGroupViewController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import Cocoa

final class CurtainViewController: NSViewController {
    
    @IBOutlet weak var secureText: NSSecureTextField!
    
    var size = CGSize.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        
        self.secureText.delegate = self
        
        self.view.wantsLayer = true
        let image = NSImage(named: NSImage.Name( "curtain"))
        self.view.layer!.contents = image
        
        self.preferredContentSize = size
    }
    
    @IBAction func confirm(_ sender: Any) {
        let passWord = Defaults.string(forKey: "password")
        
        if passWord == secureText.stringValue || passWord == nil {
            if presentingViewController != nil {
                presentingViewController!.dismiss(self)
            }
        } else {
//            shakeLogin()
            secureText.shake(withCompletion: nil)
        }
    }
    
//    private func shakeLogin() {
//        
//        let numberOfShakes = 5
//        let durationOfShake = 0.5
//        let vigourOfShake: CGFloat = 0.05
//        
//        let frame: CGRect = (self.view.window!.frame)
//        let shakeAnimation = CAKeyframeAnimation()
//        
//        let shakePath = CGMutablePath()
//        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))
//        for _ in 1 ... numberOfShakes {
//            shakePath.addLine(to: CGPoint(x: NSMinX(frame) - frame.size.width * vigourOfShake, y: NSMinY(frame)))
//            shakePath.addLine(to: CGPoint(x: NSMinX(frame) + frame.size.width * vigourOfShake, y: NSMinY(frame)))
//        }
//        shakePath.closeSubpath()
//        
//        shakeAnimation.path = shakePath
//        shakeAnimation.duration = CFTimeInterval(durationOfShake)
//        self.view.window?.animations = ["frameOrigin": shakeAnimation]
//        let origin = self.view.window?.frame.origin
//        self.view.window?.animator().setFrameOrigin(origin!)
//    }
    
}

extension CurtainViewController: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            confirm(textView)
            return true
//        } else if (commandSelector == #selector(NSResponder.deleteForward(_:))) {
//            // Do something against DELETE key
//            return true
//        } else if (commandSelector == #selector(NSResponder.deleteBackward(_:))) {
//            // Do something against BACKSPACE key
//            return true
//        } else if (commandSelector == #selector(NSResponder.insertTab(_:))) {
//            // Do something against TAB key
//            return true
//        } else if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
//            // Do something against ESCAPE key
//            return true
        }
        
        // return true if the action was handled; otherwise false
        return false
    }
    
}
