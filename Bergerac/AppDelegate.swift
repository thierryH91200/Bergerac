//
//  AppDelegate.swift
//  Bergerac
//
//  Created by thierryH24 on 19/04/2022.
//


import Cocoa

import NotificationCenter
import UserNotifications

//import Sparkle


//typealias TFDatePicker = NSDatePicker

@main
class AppDelegate: NSObject, NSApplicationDelegate , NSUserNotificationCenterDelegate {
    
    var splashScreenWindowController: SplashScreenWindowController! = nil
//    @IBOutlet var checkForUpdatesMenuItem: NSMenuItem!

    
    typealias TFDate = NSDatePicker
    
//    let updaterController: SPUStandardUpdaterController
//
//    override init() {
//        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
//        // This is where you can also pass an updater delegate if you need one
//        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
//    }
//

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSUserNotificationCenter.default.delegate = self
        
        Defaults.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
//        checkForUpdatesMenuItem.target = updaterController
//        checkForUpdatesMenuItem.action = #selector(SPUStandardUpdaterController.checkForUpdates(_:))

    }
    
//    @IBAction func updateButtonClicked(_ sender: Any) {
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        updateButton.target = appDelegate.updaterController
//        updateButton.action = #selector(SPUStandardUpdaterController.checkForUpdates(_:))
//
//
//    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, shouldPresent notification: UNNotification) -> Bool
        {
        return true
        }

    func applicationWillFinishLaunching(_ notification: Notification) {
        
        let kUserDefaultsKeyVisibleColumns = "kUserDefaultsKeyVisibleColumns"
        
            // Register user defaults. Use a plist in real life.
        var dict = [String : Bool]()
        dict["datePointage"]   = false
        dict["dateTransaction"]  = false
        dict["comment"]        = false
        dict["rubric"]       = false
        dict["category"]      = false
        dict["mode"]           = false
        dict["bankStatement"]  = false
        dict["statut"]         = false
        dict["checkNumber"]    = false
        
        dict["amount"]        = false
        dict["depense"]        = true
        dict["recette"]        = true
        dict["solde"]          = false
        dict["liee"]           = false
        var defaults           = [String :Any]()
        defaults[kUserDefaultsKeyVisibleColumns] = dict as Any
        UserDefaults.standard.register(defaults: defaults)
        UserDefaults.standard.set(defaults, forKey: kUserDefaultsKeyVisibleColumns)
        // for verify
//        let dict1 = UserDefaults.standard.dictionary(forKey: kUserDefaultsKeyVisibleColumns)

            // Create the shared document controller.
        _ = TulsiDocumentController()
    }
    
        /// applicationShouldOpenUntitledFile
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        splashScreenWindowController = SplashScreenWindowController()
        splashScreenWindowController.showWindow(self)
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ sender: NSApplication) -> Bool {
        return true
    }
    
        // Reopen mainWindow, when the user clicks on the dock icon.
//    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
//        if flag == false {
//            splashScreenWindowController = SplashScreenWindowController()
////            _ = self.splashScreenWindowController
////            if let splashScreenWindowController = self.splashScreenWindowController {
//                splashScreenWindowController.showWindow(self)
//                return false
////            }
//        }
//        return true
//    }
    
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Document")
        
        /*add necessary support for migration*/
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions =  [description]
        /*add necessary support for migration*/
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    @IBAction func saveAction(_ sender: Any?) {
        
        let context = persistentContainer.viewContext
        
        context.perform {
            
            if !(context.commitEditing()) {
                NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
            }
            if context.hasChanges == true {
                do {
                    try context.save()
                    print("save Action")
                } catch {
                        // Customize this code block to include application-specific recovery steps.
                    let nserror = error as NSError
                    NSApplication.shared.presentError(nserror)
                }
                context.reset()
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
            // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }
    
   // Returns a value that indicates if the app should terminate.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
            // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            
                // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            alert.showsSuppressionButton = true

            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
            // If we got here, it is time to quit.
        return .terminateNow
    }
    
}


