    //
    //  AccountModalWindowController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import AppKit

final class AccountModalWindowController: NSWindowController {
    
    @IBOutlet weak var gridView: NSGridView!
    @IBOutlet weak var libelleCompte: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var numCompte: NSTextField!
    @IBOutlet weak var nomTitulaire: NSTextField!
    @IBOutlet weak var prenomTitulaire: NSTextField!
    @IBOutlet weak var soldeInitial: NSTextField!
    
    @IBOutlet weak var horizontal1: NSBox!
    @IBOutlet weak var horizontal2: NSBox!
    @IBOutlet weak var typeAccount: NSPopUpButton!
    
    @IBOutlet weak var mode: NSButton!
    
    var account :  EntityAccount?
    var edition = false
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .semitransient
        let popOverModalViewController = PopOverModalViewController()
        popOverModalViewController.delegate = self
        popover.contentViewController = popOverModalViewController
        return popover
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let cell1 = gridView.cell(for: horizontal1)!
        cell1.row!.topPadding = 4
        cell1.row!.mergeCells(in: NSRange(location: 0, length: 2))

        let cell = gridView.cell(for: horizontal2)!
        cell.row!.topPadding = 4
        cell.row!.mergeCells(in: NSRange(location: 0, length: 2))

        mode.isBordered = false //Important
        mode.title = Localizations.Transaction.ModeCreation
        mode.bezelStyle = .texturedSquare
        mode.wantsLayer = true
        mode.layer?.backgroundColor = NSColor.green.cgColor

        if edition == true {
            libelleCompte.stringValue = account?.name ?? "Name"
            soldeInitial.doubleValue = account?.initAccount?.realise ?? 0
            nomTitulaire.stringValue = (account?.identity?.name) ?? "name"
            prenomTitulaire.stringValue = (account?.identity?.surName) ?? "surName"
            numCompte.stringValue = (account?.initAccount?.codeAccount) ?? "codeAccount"
            
            let image = Image.shared.getImage(name: (account?.nameImage)!)            
            imageView.image = image
            
            typeAccount.selectItem(at: Int(account?.type ?? 0))
            
            mode.title = Localizations.Transaction.ModeEdition
            mode.layer?.backgroundColor = NSColor.orange.cgColor
        }
    }
    
    override var windowNibName: NSNib.Name? {
        return  "AccountModalWindowController"
    }
    
    @IBAction func didTapCancelButton(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        self.window!.close()
    }
    
    @IBAction func didTapDoneButton(_ sender: NSButton) {
        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        self.window!.close()
    }
    
    @IBAction func show(_ sender: NSButton) {
        
        let positioningView = sender
        let positioningRect = NSRect.zero
        let preferredEdge = NSRectEdge.minY
        
        popover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
    }

}

extension AccountModalWindowController: PopOverModalDelegate
{
    func changeView(_ name: String)
    {
        let image = Image.shared.getImage(name: name)
        imageView.image = image
    }
    
}

// let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true).first as! String
// self.fileName is whatever the filename that you need to append to base directory here.
//
// let path = documentsDirectory.stringByAppendingPathComponent(self.fileName)
//
// let success = data.writeToFile(path, atomically: true)
// if !success { // handle error }
