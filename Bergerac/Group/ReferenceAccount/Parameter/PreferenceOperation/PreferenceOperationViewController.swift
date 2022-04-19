import AppKit

final class PreferenceOperationViewController: NSViewController {
    
    @IBOutlet weak var comboBoxCategory: NSComboBox!
    @IBOutlet weak var comboBoxRubrique: NSComboBox!
    @IBOutlet weak var comboBoxStatut: NSComboBox!
    @IBOutlet weak var comboBoxMode: NSComboBox!
    @IBOutlet weak var signeButton: NSButton!
    
    var entityPreference: EntityPreference?
    var entityRubrique = [EntityRubric]()
    var entityMode = [EntityPaymentMode]()
    
    var statuts = [String]()

    override var nibName: NSNib.Name? {
        return NSNib.Name( "PreferenceOperationViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NotificationCenter.receive( self, selector: #selector(updateChangeCompte(_:)), name: .updateAccount)
        updateData()
    }
    
    @objc func updateChangeCompte(_ notification: Notification) {
        
        updateData()
    }
    
    func updateData() {
        
        self.entityPreference = Preference.shared.getAllDatas()
        
        entityMode = PaymentMode.shared.getAllDatas()
        comboBoxMode.usesDataSource = true
        comboBoxMode.dataSource = self
        comboBoxMode.delegate = self
        var i = entityMode.firstIndex { $0 === entityPreference?.paymentMode }
        comboBoxMode.selectItem(at: i!)

        let planifie = Localizations.Statut.Planifie
        let engaged = Localizations.Statut.Engaged
        let realise = Localizations.Statut.Realise
        statuts = [planifie, engaged, realise]
        comboBoxStatut.removeAllItems()
        comboBoxStatut.addItems(withObjectValues: statuts)
        i = Int((entityPreference?.statut)!)
        comboBoxStatut.selectItem(at: i!)
        comboBoxStatut.delegate = self

        self.entityRubrique = Rubric.shared.getAllDatas()
        comboBoxRubrique.usesDataSource = true
        comboBoxRubrique.dataSource = self
        comboBoxRubrique.delegate = self
        i = entityRubrique.firstIndex { $0 == entityPreference?.category?.rubric }
        comboBoxRubrique.selectItem(at: i!)

        comboBoxCategory.usesDataSource = true
        comboBoxCategory.dataSource = self
        comboBoxCategory.delegate = self
        var entityCategory = entityRubrique[i!].category?.allObjects as! [EntityCategory]
        entityCategory = entityCategory.sorted { $0.name! < $1.name! }
        i = entityCategory.firstIndex { $0 === entityPreference?.category }
        comboBoxCategory.selectItem(at: i!)
        
        signeButton.state = entityPreference?.signe == true ? .on : .off
    }
    
    @IBAction func actionSigne(_ sender: Any) {
        entityPreference?.signe = signeButton.state == .on ? true : false
    }
}
