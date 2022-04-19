

import AppKit


    //    extension StoryboardProtocol where Self: UIViewController {
    //        static func instantiate() -> Self {
    //             let id = String(describing: self)
    //             let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    //             return storyboard.instantiateViewController(withIdentifier: id) as! Self
    //        }
    //    }


extension ViewController: SourceListDelegate
{
    func controller() -> ListTransactionsController {
        
        let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "IDListTransactions")
        let storyboard = NSStoryboard(name: "ListTransactionsController", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? ListTransactionsController
        return vc!
    }

    func changeView(_ name: String)
    {
        var  vc = NSView()
        
        var isSplitRightHidden = false
        var isSplitCenterHidden = false
        
        switch name
        {
        case "Liste des transactions":
            
            self.listTransactionsController = controller()
//            self.listTransactionsController = ListTransactionsController()
            listTransactionsController?.secondary = false
            
            vc = (listTransactionsController?.view)!
            listTransactionsController?.setUpDatePicker()
            listTransactionsController?.datePicker.isEnabled = true

            setUpViewTransaction()
            listTransactionsController?.delegate = transactionController
            
            isSplitRightHidden = false
            isSplitCenterHidden =  true
            transactionViewSecondary.isHidden = true
            
            let mainView = splitViewPrincipal.subviews.first!
            mainView.isHidden = false
            segmentedControl?.setEnabled(false, forSegment: 1)
            segmentedControl?.setSelected(true, forSegment: 2)
            
        case "Courbe de trésorerie":
            self.tresorerieController = TresorerieViewController()
            vc = (tresorerieController?.view)!
            
            setUpGroupeListTransactionsSecondary(true)
            tresorerieController?.delegate = listTransactionsController
            
            isSplitRightHidden = true
            isSplitCenterHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(true, forSegment: 2)

        case "Relevé bancaire":
            self.listBankStatementController = ListBankStatementController()
            vc = (self.listBankStatementController?.view)!
           
            setUpGroupeListTransactionsSecondary(true)
            listBankStatementController?.delegate = listTransactionsController

            isSplitRightHidden = true
            isSplitCenterHidden =  false
            segmentedControl?.setEnabled(false, forSegment: 1)
            segmentedControl?.setSelected(true, forSegment: 2)
            
        case "Rubrique Pie":
            self.rubricPieController = RubricPieController()
            vc = (self.rubricPieController?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.rubricPieController?.delegate = listTransactionsController
            self.rubricPieController?.setDataHorizontal()
            
            isSplitRightHidden = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Site Web de la banque":
            self.webViewController = WebViewController()
            vc = (webViewController?.view)!
            
            transactionViewSecondary.isHidden = true
            isSplitRightHidden = true
            isSplitCenterHidden =  true
            segmentedControl.setEnabled(false, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Recette Depense Pie":
            self.incomeExpensePieController = IncomeExpensePieController()
            vc = (incomeExpensePieController?.view)!
            
            setUpGroupeListTransactionsSecondary()
            incomeExpensePieController?.delegate = listTransactionsController
            incomeExpensePieController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Recette Depense Bar":
            self.incomeExpenseBarController = IncomeExpenseBarController()
            vc = (incomeExpenseBarController?.view)!
            
            setUpGroupeListTransactionsSecondary()
            incomeExpenseBarController?.delegate = listTransactionsController
            incomeExpenseBarController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            segmentedControl.setEnabled(true, forSegment: 1)
            segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Rubrique Bar":
            self.rubricBarController = RubricBarController()
            vc = (rubricBarController?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.rubricBarController?.delegate = listTransactionsController
            self.rubricBarController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Categorie Bar":
            self.categoryBarController = CategoryBarController()
            vc = (categoryBarController?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.categoryBarController?.delegate = listTransactionsController
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Categorie Bar1":
            self.categoryBarController1 = CategoryBarController1()
            vc = (categoryBarController1?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.categoryBarController1?.delegate = listTransactionsController
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Mode de paiement":
            self.modePaiementPieController = PaymentModePieController()
            vc = (modePaiementPieController?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.modePaiementPieController?.delegate = listTransactionsController
            self.modePaiementPieController?.setDataHorizontal()
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Settings":
            self.parameterController = ParameterController()
            vc = ((self.parameterController)?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.parameterController?.rubriqueViewController?.delegate = listTransactionsController
            self.parameterController?.modeOfPaymentViewController?.delegate = listTransactionsController
            
            isSplitRightHidden  = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "Scheduler":
            self.schedulerViewController = SchedulerViewController()
            vc = (schedulerViewController?.view)!
            
            self.setUpViewSaisieEcheancier()
            self.schedulerViewController?.delegate = echeanciersSaisieController
            self.echeanciersSaisieController?.delegate = schedulerViewController
            
            isSplitRightHidden = false
            isSplitCenterHidden =  true
            self.transactionViewSecondary.isHidden = true
            self.segmentedControl.setEnabled(false, forSegment: 1)
            self.segmentedControl.setEnabled(true, forSegment: 2)
            
        case "Identite":
            self.identiteViewController = IdentiteViewController()
            vc = (identiteViewController?.view)!
            
            isSplitRightHidden              = true
            isSplitCenterHidden             =  true
            self.transactionViewSecondary.isHidden = true
            self.segmentedControl.setEnabled(false, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        case "AdvancedFilterViewController":
            self.advancedFilterViewController = AdvancedFilterViewController()
            vc = (advancedFilterViewController?.view)!
            
            self.setUpGroupeListTransactionsSecondary()
            self.advancedFilterViewController?.delegate = listTransactionsController
            
            isSplitRightHidden = true
            isSplitCenterHidden =  false
            self.segmentedControl.setEnabled(true, forSegment: 1)
            self.segmentedControl.setEnabled(false, forSegment: 2)
            
        default:
            break
        }
        
        Commun.shared.addSubview(subView: vc, toView: tableTargetView)
        
        vc.translatesAutoresizingMaskIntoConstraints = false
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["vc"] = vc
        tableTargetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        tableTargetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        
        setSplitRight( isSplitRightHidden)
        setSplitCenter( isSplitCenterHidden)
        splitViewPrincipal.adjustSubviews()
    }
    
}
