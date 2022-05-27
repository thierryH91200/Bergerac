    //
    //  MainWindowContoller.swift
    //  MainWindowContoller
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import Cocoa

class MainWindowController: NSWindowController, NSToolbarItemValidation {
    
    /// Items for the `NSMenuToolbarItem`
    ///
    ///              #selector(appearanceSelection(_:))
    var actionsMenu: NSMenu = {
        var menu = NSMenu(title: "")
        let menuItem1 = NSMenuItem(title: "Light", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        let menuItem2 = NSMenuItem(title: "Dark", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        menu.items = [menuItem1, menuItem2]
        return menu
    }()
    
    var colorMenu: NSMenu = {
        var menu = NSMenu(title: "")
        let menuItem0 = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menuItem0.image = NSImage(named: NSImage.colorPanelName)
        let menuItem1 = NSMenuItem(title: "Unie", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        let menuItem2 = NSMenuItem(title: "Income/Expense", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        let menuItem3 = NSMenuItem(title: "Rubric", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        let menuItem4 = NSMenuItem(title: "Payment Mode", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        let menuItem5 = NSMenuItem(title: "Statut", action: #selector(appearanceSelection(_:)), keyEquivalent: "")
        menu.items = [menuItem0, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5]
        return menu
    }()
    
    var menuSearch: NSMenu = {
        let allMenuItem = NSMenuItem()
        allMenuItem.title =  Localizations.searchMenu.title.all
//        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        let fNameMenuItem = NSMenuItem()
        fNameMenuItem.title = Localizations.searchMenu.title.comment
//        fNameMenuItem.target = self
        fNameMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        let cNameMenuItem = NSMenuItem()
        cNameMenuItem.title = Localizations.searchMenu.title.category
//        cNameMenuItem.target = self
        cNameMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        let rNameMenuItem = NSMenuItem()
        rNameMenuItem.title = Localizations.searchMenu.title.rubric
//        rNameMenuItem.target = self
        rNameMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        var menu = NSMenu(title: "")
        menu.removeAllItems()
        menu.addItem(allMenuItem)
        menu.addItem(fNameMenuItem)
        menu.addItem(cNameMenuItem)
        menu.addItem(rNameMenuItem)
        return menu
    }()

    
    // MARK: - Titlebar Accessory View
    // This view appears below the titlebar or toolbar (if you have one)
    // An example of this would be Safari's "Favorites Bar"
    
    var titlebarAccessoryViewController: CustomTitlebarAccessoryViewController?
    var titlebarAccessoryViewControllerToggleButton: NSToolbarItem?
    private var titlebarAccessoryViewIsHidden = false

    
    // MARK: - Window Lifecycle
    

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
//        createMenuForSearchField()
//        searchField.delegate = self
//
//        setUpPopUpColor()
                
        for window in NSApp.windows {
            if let splashScreenWindow = window.windowController as? SplashScreenWindowController {
                splashScreenWindow.close()
            }
        }
        
        self.configureToolbar()

    }
    
    // MARK: - Toolbar Validation
    
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool
    {
         print("Validating \(item.itemIdentifier)")

        // Use this method to enable/disable toolbar items as user takes certain
        // actions. For example, so items may not be applicable if a certain UI
        // element is selected. This is called on your behalf. Return false if
        // the toolbar item needs to be disabled.

        //  Maybe you want to not enable more actions if nothing in your app
        //  is selected. Set your condition inside this `if`.
        if  item.itemIdentifier == NSToolbarItem.Identifier.toolbarMoreActions {
            return true
        }

        //  Maybe you want to not enable the share menu if nothing in your app
        //  is selected. Set your condition inside this `if`.
        if  item.itemIdentifier == NSToolbarItem.Identifier.toolbarShareButtonItem {
            return true
        }

        //  Example of returning false to demonstrate a disabled toolbar item.
        if  item.itemIdentifier == NSToolbarItem.Identifier.toolbarItemMoreInfo {
            return false
        }
        
//          Feel free to add more conditions for your other toolbar items here...

        return true
    }

    
    private func configureToolbar()
    {
        if  let unwrappedWindow = self.window {

            let newToolbar = NSToolbar(identifier: NSToolbar.Identifier.mainWindowToolbarIdentifier)
            newToolbar.delegate = self
            newToolbar.allowsUserCustomization = true
            newToolbar.autosavesConfiguration = true
            newToolbar.displayMode = .default

            // Example on center-pinning a toolbar item
            newToolbar.centeredItemIdentifier = NSToolbarItem.Identifier.toolbarLightDarItem

            unwrappedWindow.title = "My Great App"
            if #available(macOS 11.0, *) {
                unwrappedWindow.subtitle = "Toolbar Example"
                // The toolbar style is best set to .automatic
                // But it appears to go as .unifiedCompact if
                // you set as .automatic and titleVisibility as
                // .hidden
                unwrappedWindow.toolbarStyle = .automatic
            }

            // Hiding the title visibility in order to gain more toolbar space.
            // Set this property to .visible or delete this line to get it back.
            unwrappedWindow.titleVisibility = .visible

            unwrappedWindow.toolbar = newToolbar
            unwrappedWindow.toolbar?.validateVisibleItems()
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
    
    // MARK: - Toolbar Item Custom Actions
    @IBAction func testAction(_ sender: Any)
    {
        if  let toolbarItem = sender as? NSToolbarItem {
            print("Clicked \(toolbarItem.itemIdentifier.rawValue)")
        }
    }

}

// MARK: - Search Field Delegate
extension MainWindowController: NSSearchFieldDelegate
{
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("Search field did start receiving input")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("Search field did end receiving input")
        sender.resignFirstResponder()
    }
}

// MARK: - Sharing Service Picker Toolbar Item Delegate

extension MainWindowController: NSSharingServicePickerToolbarItemDelegate
{
    func items(for pickerToolbarItem: NSSharingServicePickerToolbarItem) -> [Any] {
        // Compose an array of items that are sharable such as text, URLs, etc.
        // depending on the context of your application (i.e. what the user
        // current has selected in the app and/or they tab they're in).
        let sharableItems = [URL(string: "https://www.apple.com/")!]
        return sharableItems
    }
}




// MARK: - Titlebar Accessory View
extension MainWindowController
{
//    private func configureTitlebarAccessoryView()
//    {
//        if  let titlebarController = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.customTitlebarAccessoryViewController) as? CustomTitlebarAccessoryViewController {
//            titlebarController.layoutAttribute = .bottom
//            titlebarController.fullScreenMinHeight = titlebarController.view.bounds.height
//            self.window?.addTitlebarAccessoryViewController(titlebarController)
//            self.titlebarAccessoryViewController = titlebarController
//            self.titlebarAccessoryViewController?.isHidden = self.titlebarAccessoryViewIsHidden
//        }
//    }
    
    @IBAction func toggleTitlebarAccessory(_ sender: Any)
    {
        self.titlebarAccessoryViewIsHidden.toggle()
        self.titlebarAccessoryViewController?.isHidden = self.titlebarAccessoryViewIsHidden
        
        if  self.titlebarAccessoryViewIsHidden {
            self.titlebarAccessoryViewControllerToggleButton?.label = "Show"
            self.titlebarAccessoryViewControllerToggleButton?.toolTip = "Shows additional accessories"
            if  #available(macOS 11.0, *) {
                self.titlebarAccessoryViewControllerToggleButton?.image = NSImage(systemSymbolName: "menubar.arrow.up.rectangle", accessibilityDescription: "")
            } else {
                self.titlebarAccessoryViewControllerToggleButton?.image = NSImage(named: NSImage.touchBarGoUpTemplateName)
            }
        } else {
            self.titlebarAccessoryViewControllerToggleButton?.label = "Hide"
            self.titlebarAccessoryViewControllerToggleButton?.toolTip = "Hides additional accessories"
            if  #available(macOS 11.0, *) {
                self.titlebarAccessoryViewControllerToggleButton?.image = NSImage(systemSymbolName: "menubar.arrow.down.rectangle", accessibilityDescription: "")
            } else {
                self.titlebarAccessoryViewControllerToggleButton?.image = NSImage(named: NSImage.touchBarGoDownTemplateName)
            }
        }
    }
}




