import Cocoa

final class ParameterController: NSViewController {

    @IBOutlet weak var tabView: NSTabView!
    
    var chequiersViewController: ChequiersViewController!
    var modeOfPaymentViewController: ModeOfPaymentViewController!
    var rubriqueViewController: RubriqueViewController!
    var preferenceTransactionViewController: PreferenceOperationViewController!
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        
        NotificationCenter.remove( chequiersViewController!, name: .updateAccount)
        
        NotificationCenter.remove( modeOfPaymentViewController!, name: .updateAccount)
        NotificationCenter.remove( modeOfPaymentViewController!, name: .selectionDidChangeTable)

        NotificationCenter.remove( rubriqueViewController!, name: .updateAccount)
        NotificationCenter.remove( rubriqueViewController!, name: .selectionDidChangeOutLine)

        NotificationCenter.remove( preferenceTransactionViewController!, name: .updateAccount)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chequiersViewController = ChequiersViewController()
        modeOfPaymentViewController = ModeOfPaymentViewController()
        rubriqueViewController = RubriqueViewController()
        preferenceTransactionViewController = PreferenceOperationViewController()

        let chequiersItem = NSTabViewItem(viewController: chequiersViewController)
        chequiersItem.label = Localizations.PaymentMethod.Check
        
        let modeItem = NSTabViewItem(viewController: modeOfPaymentViewController)
        modeItem.label = Localizations.General.Mode_Payment
        
        let rubricItem = NSTabViewItem(viewController: rubriqueViewController)
        rubricItem.label = Localizations.General.Rubric
        
        let transactionItem = NSTabViewItem(viewController: preferenceTransactionViewController)
        transactionItem.label = Localizations.General.Transaction

        let items = tabView.tabViewItems
        for item in items {
            tabView.removeTabViewItem(item)
        }
        tabView.addTabViewItem(rubricItem)
        tabView.addTabViewItem(modeItem)
        tabView.addTabViewItem(transactionItem)
        tabView.addTabViewItem(chequiersItem)
        tabView.selectTabViewItem(at: 0)
    }
    
}
