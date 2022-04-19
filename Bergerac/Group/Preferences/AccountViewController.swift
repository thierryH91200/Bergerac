import AppKit

final class AccountViewController: NSViewController, Preferenceable {
    
    let toolbarItemTitle = "Account"
    let toolbarItemIcon = NSImage(named: NSImage.everyoneName)!

    
    @IBOutlet weak var oldPassWord: NSSecureTextField!
    @IBOutlet weak var newPassWord: NSSecureTextField!
    @IBOutlet weak var confirmPassWord: NSSecureTextField!
    
    @IBOutlet weak var textPassWord: NSTextField!
    @IBOutlet weak var textInfo: NSTextField!
    
    let defaults = UserDefaults.standard
    
    override var nibName: NSNib.Name? {
        return  "AccountViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let passWord = defaults.string(forKey: "password")
        if passWord == nil {
            textPassWord.isHidden = true
            oldPassWord.isHidden = true
        }
        oldPassWord.delegate = self
        newPassWord.delegate = self
        confirmPassWord.delegate = self
        textInfo.stringValue = ""

    }
    
    @IBAction func SaveAll(_ sender: Any) {
        
        let passWord = defaults.string(forKey: "password")
        if passWord != nil {
            if passWord != oldPassWord.stringValue {
                shakeLogin()
                textInfo.stringValue = "Password invalid"
                textInfo.textColor = .red
                return
            }
        }
        
        let new = newPassWord.stringValue
        let confirm = confirmPassWord.stringValue
        
        if new == confirm {
            defaults.set(new, forKey: "password")
            textInfo.stringValue = "Password valid"
            textInfo.textColor = .green

            return
        }
        textInfo.stringValue = "les mots de passe ne correspondent pas"
        textInfo.textColor = .red
        shakeLogin()
    }
    
    private func shakeLogin() {
        
        let numberOfShakes = 5
        let durationOfShake = 0.5
        let vigourOfShake: CGFloat = 0.05
        
        let frame: CGRect = (self.view.window!.frame)
        let shakeAnimation = CAKeyframeAnimation()
        
        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: frame.minX, y: frame.minY))
        for _ in 1 ... numberOfShakes {
            shakePath.addLine(to: CGPoint(x: frame.minX - frame.size.width * vigourOfShake, y: frame.minY))
            shakePath.addLine(to: CGPoint(x: frame.minX + frame.size.width * vigourOfShake, y: frame.minY))
        }
        shakePath.closeSubpath()
        
        shakeAnimation.path = shakePath
        shakeAnimation.duration = CFTimeInterval(durationOfShake)
        self.view.window?.animations = ["frameOrigin": shakeAnimation]
        let origin = self.view.window?.frame.origin
        self.view.window?.animator().setFrameOrigin(origin!)
    }
}

extension AccountViewController: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            SaveAll(textView)
            return true
        }
        return false
    }
}

