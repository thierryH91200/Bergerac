import AppKit

final class AdvancedFilterViewController: NSViewController {

    public var delegate: FilterDelegate?
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    var predicate: NSPredicate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        let templateCompoundTypes = NSPredicateEditorRowTemplate( compoundTypes: [.and, .or, .not] )

        let template1 = RowTemplateRelationshipDate(leftExpressions: [NSExpression(forKeyPath: "Date Operation")], leftEntity: "dateOperation")
        let template2 = RowTemplateRelationshipDate(leftExpressions: [NSExpression(forKeyPath: "Date Pointage")], leftEntity: "datePointage")
        
        let template3 = RowTemplateRelationshipStatus(leftExpressions: [NSExpression(forKeyPath: "Status")], leftEntity: "statut")
        let template4 = RowTemplateRelationshipMode(leftExpressions: [NSExpression(forKeyPath: "Mode")], leftEntity: "paymentMode")
        
        let template5 = RowTemplateRelationshipLibelle(leftExpressions: [NSExpression(forKeyPath: "Libelle")])
        let template6 = RowTemplateRelationshipRubrique(leftExpressions: [NSExpression(forKeyPath: "Rubric")])
        let template7 = RowTemplateRelationshipCategory(leftExpressions: [NSExpression(forKeyPath: "Category")])
        let template8 = RowTemplateRelationshipMontant(leftExpressions: [NSExpression(forKeyPath: "Montant")])

        predicateEditor.rowTemplates.removeAll()
        predicateEditor.rowTemplates = [ templateCompoundTypes, template1, template2, template3, template4, template5, template6, template7, template8]
        
        predicateEditor.canRemoveAllRows = false

        if predicateEditor.predicate == nil {
            predicateEditor.addRow(self)
        }
    }
    
    @IBAction func predicateEditorAction(_ sender: NSButton) {
//        print("predicate value changed")
    }
    
    // MARK: - generateQuery
    @IBAction func generateQuery(_ sender: NSButton) {

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = predicateEditor.predicate
        print("predicateEditor : ", predicateEditor.predicate ?? "predicate default")
        print(predicateEditor.predicate?.description ?? "predicateEditor.predicate")

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2!])

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        self.delegate?.applyFilter( fetchRequest)
    }
}

