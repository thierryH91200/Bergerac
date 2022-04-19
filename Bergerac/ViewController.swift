    //
    //  ViewController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 12/10/2021.
    //


import Cocoa
import UserNotifications

class ViewController: NSViewController , UNUserNotificationCenterDelegate{
    
    var windowController: MainWindowController!
    
    @IBOutlet weak var accountView: NSView!
    @IBOutlet weak var tableTargetView: NSView!
    @IBOutlet weak var transactionView: NSView!
    @IBOutlet weak var transactionViewSecondary: NSView!
    @IBOutlet weak var affichageView: NSView!
    
    var segmentedControl: NSSegmentedControl!
        //    @IBOutlet weak var searchField: NSSearchField!
        //    @IBOutlet weak var colorPopUp: NSPopUpButton!
    
    @IBOutlet weak var splitViewPrincipal: NSSplitView!
    @IBOutlet weak var splitViewGauche: NSSplitView!
    @IBOutlet weak var splitViewCentre: NSSplitView!
    
    let context = mainObjectContext
    
    var listBankStatementController  : ListBankStatementController?
    var listTransactionsController   : ListTransactionsController?
    var transactionController        : TransactionViewController?
    var sourceListViewController     : SourceListViewController?
    var groupeAccountViewController  : AccountGroupViewController?
    
    var tresorerieController         : TresorerieViewController?
    var rubricPieController          : RubricPieController?
    var categoryBarController        : CategoryBarController?
    var categoryBarController1       : CategoryBarController1?
    
    var modePaiementPieController    : PaymentModePieController?
    var incomeExpenseBarController   : IncomeExpenseBarController?
    var incomeExpensePieController   : IncomeExpensePieController?
    var rubricBarController          : RubricBarController?
    
    var parameterController          : ParameterController?
    
    var schedulerViewController      : SchedulerViewController?
    var echeanciersSaisieController  : SchedulersSaisieController?
    
    var identiteViewController       : IdentiteViewController?
    var webViewController            : WebViewController?
    var advancedFilterViewController : AdvancedFilterViewController?
    
    private var center: UNUserNotificationCenter?
    private let handler = NotificationHandler()
    private let notifyCategoryIdentifier = "test"
    private let notificationsHelper = NotificationsHelper()
    
        //
        // Called after the view controller’s view has been loaded into memory.
        //
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Do any additional setup after loading the view.
        
        guard context != nil else { return }
        
        var entityAccount = [EntityAccount]()
        let request = NSFetchRequest<EntityAccount>(entityName: "EntityAccount")
        let predicate = NSPredicate(format: "isAccount == YES")
        request.predicate = predicate
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            entityAccount = try context!.fetch(request)
        } catch { print(error) }
        
        if entityAccount.isEmpty {
            self.groupeAccountViewController?.addAccount(entityAccount)
        } else {
            currentAccount = entityAccount.first
        }
        
        self.setUpGroupeAccount()
        self.setUpSourceList()
        
        self.splitViewPrincipal.autosaveName = NSSplitView.AutosaveName( "splitViewPrincipal")
        self.splitViewGauche.autosaveName = NSSplitView.AutosaveName( "splitViewLeft")
        self.splitViewCentre.autosaveName = NSSplitView.AutosaveName( "splitViewCenter")
        
        let mainViews = splitViewPrincipal.subviews
        for mainView in mainViews {
            mainView.isHidden = false
        }
        
        self.addObserver(self, forKeyPath: "view.window.windowController", options: .new, context: nil)
        
        notificationCenter.shared.initNotifications()
        notificationCenter.shared.generateNotification(title: "Bergerac", body: "Notification", subtitle: "totally", sound: true)
    }
    
    override var representedObject: Any? {
        didSet {
                // Update the view, if already loaded.
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "view.window.windowController")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let windowController = self.view.window?.windowController as? MainWindowController {
            self.windowController = windowController
            segmentedControl = windowController.segmentedControl
        }
    }
    
    private func setUpGroupeAccount()
    {
        self.groupeAccountViewController = AccountGroupViewController()
        let subView = self.groupeAccountViewController?.view
        Commun.shared.addSubview(subView: subView!, toView: accountView)
        
        Commun.shared.setUpLayoutConstraints(item: self.groupeAccountViewController!.view, toItem: accountView)
        self.groupeAccountViewController!.view.setFrameSize( NSSize(width: 100, height: 200))
    }
    
    private func setUpSourceList()
    {
        self.sourceListViewController = SourceListViewController()
        self.sourceListViewController?.delegate = self
        let subView = self.sourceListViewController?.view
        Commun.shared.addSubview(subView: subView!, toView: affichageView)
        
        Commun.shared.setUpLayoutConstraints(item: self.sourceListViewController!.view, toItem: affichageView)
        self.sourceListViewController!.view.setFrameSize( NSSize(width: 100, height: 200)) //affichageView.bounds
    }
    
    func setUpViewTransaction()
    {
        self.transactionController = TransactionViewController()
        Commun.shared.addSubview(subView: transactionController!.view, toView: transactionView)
        
        Commun.shared.setUpLayoutConstraints(item: transactionController!.view, toItem: transactionView)
        self.transactionController!.view.frame = transactionView.bounds
        self.transactionController?.delegate = listTransactionsController
    }
    
    func setUpGroupeListTransactionsSecondary(_ forced : Bool = false)
    {
        self.listTransactionsController = controller()
        listTransactionsController?.secondary = true
        let vc = (self.listTransactionsController?.view)!
        
        if forced == true {
            self.listTransactionsController?.setUpDatePicker()
            self.listTransactionsController?.datePicker.isEnabled = true
            
        } else {
            self.listTransactionsController?.datePicker.isEnabled = false
        }
        
        self.transactionController?.delegate = listTransactionsController
        self.listTransactionsController?.delegate = transactionController
        
        Commun.shared.addSubview(subView: vc, toView: transactionViewSecondary)
        vc.translatesAutoresizingMaskIntoConstraints = false
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["vc"] = vc
        transactionViewSecondary.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        transactionViewSecondary.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[vc]|", options: [], metrics: nil, views: viewBindingsDict))
        
        setUpViewTransaction()
        listTransactionsController?.delegate = transactionController
    }
    
    func setUpViewSaisieEcheancier()
    {
        self.echeanciersSaisieController = SchedulersSaisieController()
        Commun.shared.addSubview(subView: (echeanciersSaisieController?.view)!, toView: transactionView)
        
        Commun.shared.setUpLayoutConstraints(item: echeanciersSaisieController!.view, toItem: transactionView)
        self.echeanciersSaisieController!.view.frame = transactionView.bounds
    }
    
    @IBAction  func printDocument(_ sender: Any) {
    }
    
    
    @IBAction func ActionSegmentedControl(_ sender: NSSegmentedControl) {
        
        var state = false
        
        switch sender.selectedSegment {
        case 0:
            state = segmentedControl.isSelected(forSegment: 0)
            setSplitLeft(state)
            
        case 1:
            state = segmentedControl.isSelected(forSegment: 1)
            setSplitCenter(!state)
            
        case 2:
            state = segmentedControl.isSelected(forSegment: 2)
            setSplitRight(!state)
            
        default:
            break
        }
    }
    
    func setSplitLeft( _ isHidden: Bool) {
        
            //        let newPosition: CGFloat = isHidden ? 250.0 : 0
            //        splitViewPrincipal.setPosition(  newPosition, ofDividerAt: 0)
            //        splitViewPrincipal.layoutSubtreeIfNeeded()
        
        let mainView = splitViewPrincipal.subviews.first!
        mainView.isHidden = isHidden
        
        segmentedControl.setSelected(!isHidden, forSegment: 0)
        splitViewPrincipal.adjustSubviews()
    }
    
    func setSplitCenter( _ isHidden: Bool) {
        
        if isHidden == true {
            splitViewCentre.setPosition(splitViewCentre.bounds.height, ofDividerAt: 0)
        } else {
            splitViewCentre.setPosition( splitViewCentre.bounds.height / 2, ofDividerAt: 0)
        }
        transactionViewSecondary.isHidden = isHidden
        
        segmentedControl?.setSelected(!isHidden, forSegment: 1)
        splitViewCentre.adjustSubviews()
        splitViewPrincipal.adjustSubviews()
    }
    
    func setSplitRight( _ isHidden: Bool) {
        
        let newPosition: CGFloat = isHidden ? view.frame.width - 250 : view.frame.width
        splitViewPrincipal.setPosition(newPosition, ofDividerAt: 1)
            //        splitViewPrincipal.layoutSubtreeIfNeeded()
        segmentedControl?.setSelected(!isHidden, forSegment: 2)
        
        
            //        if isHidden == true {
            //            splitViewPrincipal.setPosition(splitViewPrincipal.bounds.width, ofDividerAt: 1)
            //        } else {
            //            splitViewPrincipal.setPosition( splitViewPrincipal.bounds.width - 249, ofDividerAt: 1)
            //        }
            ////        transactionView.isHidden = isHidden
            //        segmentedControl?.setSelected(!isHidden, forSegment: 2)
            //        splitViewPrincipal.adjustSubviews()
    }
}

extension ViewController : NSSplitViewDelegate {

    func splitView(_ splitView: NSSplitView,  canCollapseSubview subview : NSView)-> Bool
    {
        if (subview == self.splitViewGauche) {
            return true;
        }
        else if (subview == self.transactionView) {
            return true
        }

        return false
    }
}
