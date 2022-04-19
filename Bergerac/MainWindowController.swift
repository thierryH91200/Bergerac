    //
    //  MainWindowContoller.swift
    //  MainWindowContoller
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import Cocoa

class MainWindowController: NSWindowController, NSSearchFieldDelegate {
    
    var viewController : ViewController!
    
//    @IBOutlet weak var splitViewPrincipal: NSSplitView!
//    @IBOutlet weak var splitViewGauche: NSSplitView!
//    @IBOutlet weak var splitViewCentre: NSSplitView!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var colorPopUp: NSPopUpButton!

    var importWindowController                 : ImportTransactionsWindowController?
    var importBankStatementWindowController    : ImportBankStatementWindowController?
    var importSchedulersWindowController       : ImportSchedulersWindowController?
    var accessoryViewController                : TTFormatViewController?
    
    var delimiter = ""
    var quote = ""
    var exportTmp = ""
    
    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [
            GeneralViewController() ,
            AccountViewController() ,
            PersonViewController()
        ]
    )

    override func windowDidLoad() {
        super.windowDidLoad()
        
        viewController = self.contentViewController! as? ViewController
        createMenuForSearchField()
        searchField.delegate = self
        
        setUpPopUpColor()
                
        for window in NSApp.windows {
            if let splashScreenWindow = window.windowController as? SplashScreenWindowController {
                splashScreenWindow.close()
            }
        }
    }
    
        // MARK: - Public static helper methods
    
        /// Returns the current window's document path
    public static func getCurrentDocument() -> String? {
        guard
            let window = NSApp.keyWindow?.windowController as? MainWindowController,
            let doc = window.document as? Document
        else { return nil }
        
        return doc.fileURL?.relativePath
    }

        
   func setUpPopUpColor() {
        var tag = Defaults.integer(forKey: "couleurMenus")
        if tag == 0 {
            tag = 1
            Defaults.set(tag, forKey: "couleurMenus")
            Defaults.set("unie", forKey: "choix couleurs")
        }
        
        let itemArray = colorPopUp.itemArray
        for item in itemArray {
            item.state = .off
            if item.tag == tag {
                item.state = .on
            }
        }
    }
}

