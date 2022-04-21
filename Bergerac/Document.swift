    //
    //  Document.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 12/10/2021.
    //

    // swift LaurineGenerator.swift -i Localizable.strings -c -o Localizations.swift

import Cocoa

final class Document: NSPersistentDocument {
    
    private var mainWindowController: MainWindowController?
    
    public var isTransient: Bool = true
    
    override init() {
        super.init()
        
            // Set managedObjectContext to mainQueue
            // https://gist.github.com/smic/4632383
        
        guard let context = self.managedObjectContext else { fatalError("no MOC") }
        if context.concurrencyType != NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType {
            guard let undoManager = context.undoManager else { fatalError("no undoManager") }
            guard let persistentStoreCoordinator = context.persistentStoreCoordinator else { fatalError("no persistentStoreCoordinator") }
            let newContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            newContext.persistentStoreCoordinator = persistentStoreCoordinator
            newContext.undoManager = undoManager
            self.managedObjectContext = newContext
        }
        
        assert(self.managedObjectContext?.concurrencyType == NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    
    func controller() -> NSWindowController {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        return windowController
    }
    
    override func makeWindowControllers() {
        
        mainObjectContext = self.managedObjectContext //else { fatalError("context is nil") }
        
        self.initializeLibraryAndShowMainWindow()
        
        let windowController = controller()
        self.addWindowController(  windowController )
    }
    
    override func data(ofType typeName: String) throws -> Data {
        
        Swift.print("data(ofType typeName: String) throws -> Data")
            // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
            // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        
        Swift.print("read(from data: Data, ofType typeName: String)")
        
        self.isTransient = false

            // Insert code here to read your document from the given data of the specified type.
            // If outError != NULL, ensure that you create and set an appropriate error when returning false.
            // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
            // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    private func setupForNilLibrary() {
        
        let context = mainObjectContext
        
            //create library
            // MARK: create root
        let root = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: context!) as! EntityAccount
        root.isRoot = true
        root.name = "Root"
        root.uuid = UUID()
        
            // MARK: create account
        let CurrentAccount = Localizations.Document.Current_account
        let Epargne = Localizations.Document.Save
        let CarteDeCrédit = Localizations.Document.Carte_de_crédit
        
        let idName = Localizations.Document.IdName
        let idPrenom = Localizations.Document.IdPrenom
        
        let pierreAccount  = Account.shared.create(nameAccount: CurrentAccount, nameImage: "icons8-museum-80", idName: idName, idPrenom: idPrenom, numAccount: "00045700E")
        pierreAccount.type = 0
        
        let marieAccount   = Account.shared.create(nameAccount: CurrentAccount, nameImage: "icons8-museum-80", idName: "Martin", idPrenom: "Marie", numAccount: "00045701F")
        marieAccount.type = 0
        
        let carteDeCredit1 = Account.shared.create(nameAccount: CarteDeCrédit, nameImage: "discount", idName: "Martin", idPrenom: "Pierre", numAccount: "00045702G")
        carteDeCredit1.type = 1
        
        let carteDeCredit2 = Account.shared.create(nameAccount: CarteDeCrédit, nameImage: "discount", idName: "Durand", idPrenom: "Jean", numAccount: "00045705K")
        carteDeCredit2.type = 1
        
        let saving  = Account.shared.create(nameAccount: Epargne, nameImage: "icons8-money-box-80", idName: "Durand", idPrenom: "Jean", numAccount: "00045703H")
        saving.type = 2
        
        let jeanAccount    = Account.shared.create(nameAccount: CurrentAccount, nameImage: "icons8-museum-80", idName: "Durand", idPrenom: "Jean", numAccount: "00045704J")
        jeanAccount.type = 0
        
            // MARK: create headers
        let header1 = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: context!) as! EntityAccount
        header1.isHeader = true
        header1.name = Localizations.General.BankAccount.Singular
        header1.uuid = UUID()
        header1.parent = root
        
        let header2 = NSEntityDescription.insertNewObject(forEntityName: "EntityAccount", into: context!) as! EntityAccount
        header2.isHeader = true
        header2.name = Localizations.General.BankAccount.Singular
        header2.uuid = UUID()
        header2.parent = root
        
            // MARK: feed header
        header1.addToChildren( pierreAccount)
        header1.addToChildren( marieAccount)
        header1.addToChildren( carteDeCredit1)
        header1.addToChildren( saving)
        
        header2.addToChildren( jeanAccount)
        header2.addToChildren( carteDeCredit2)
    }
    
    private func initializeLibraryAndShowMainWindow() {
        let entities = Account.shared.getRoot()
        
        if entities.isEmpty == true {
            self.setupForNilLibrary()
        }
    }
    
    override func defaultDraftName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let theDate = Date()
        let theDateString = dateFormatter.string(from: theDate)
        return "Bergerac_" + theDateString
    }
}
