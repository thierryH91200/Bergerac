import AppKit

final class IdentiteViewController: NSViewController {
    
    @IBOutlet var arrayControllerCompte: NSArrayController!
    @IBOutlet var arrayControllerBanque: NSArrayController!
    @IBOutlet var arrayControllerIdentite: NSArrayController!
    
    @objc var managedObjectContext: NSManagedObjectContext = mainObjectContext

    @objc dynamic var predicate =  NSPredicate(format: "account == %@", currentAccount!)
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
  //      NotificationCenter.remove(instance: self, name: .updateAccount)
    }
    
    override public func viewDidAppear()
    {
        super.viewDidAppear()
        view.window!.title = Localizations.General.Identity
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.receive( self, selector: #selector(updateChangeCompte(_:)), name: .updateAccount)

        arrayControllerCompte.setSelectionIndex(0)
        arrayControllerBanque.setSelectionIndex(0)
        arrayControllerIdentite.setSelectionIndex(0)

        updateData()
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        
        updateData()
    }
    
    @IBAction func textFieldexecuted(_ sender: Any) {
        NotificationCenter.send(.updateBalance)
    }
    
    func updateData() {
        guard currentAccount != nil else {
            return }
        
        Identity.shared.getAllDatas()
        Bank.shared.getAllDatas()
        InitAccount.shared.getAllDatas()

        arrayControllerCompte.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        arrayControllerCompte.setSelectionIndex(0)
        
        arrayControllerBanque.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        arrayControllerBanque.setSelectionIndex(0)
        
        arrayControllerIdentite.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        arrayControllerIdentite.setSelectionIndex(0)
    }
    
}

//public class Email {
//    
//    public static var stricterFilter = true // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//    
//    // Test if the specified email address is valid
//    public static func isEmailValid(email: String) -> Bool {
//        
//        var filterString: String
//        
//        if Email.stricterFilter {
//            // Strict filter string
//            filterString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
//        }
//        else {
//            // lax filter string
//            filterString = ".+@.+\\.[A-Za-z]{2}[A-Za-z]*"
//        }
//
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", filterString)
//        return emailTest.evaluate(with: email)
//    }
//}
