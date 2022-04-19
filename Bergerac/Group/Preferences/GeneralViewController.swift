
import AppKit
import LaunchAtLogin



final class GeneralViewController: NSViewController, Preferenceable {
    
    let toolbarItemTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    @IBOutlet weak var launchAtLoginButton: NSButton!
    
    override var nibName: NSNib.Name? {
        return  "GeneralViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do view setup here.
        populateLaunchAtLogin()
    }
    
    @IBAction func launchAtLoginChanged(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = (sender.state == .on)
        print("sender.state : ", sender.state == .on)
        print("LaunchAtLogin.isEnabled : ", LaunchAtLogin.isEnabled)
    }
    
    private func populateLaunchAtLogin() {
        launchAtLoginButton.state = LaunchAtLogin.isEnabled ? .on : .off
    }
}
