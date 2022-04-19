    //
    //  AccountGroupViewController.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 19/09/2021.
    //

import AppKit

final class SourceListCellView: NSTableCellView {
    
    @IBOutlet weak var nbCompte: NSTextField!
    @IBOutlet weak var inLine: NSButton!
}

final class CompteListCellView: NSTableCellView {
    
    @IBOutlet weak var titulaire: NSTextField!
    @IBOutlet weak var numCompte: NSTextField!
    @IBOutlet weak var inLine: NSButton!
}
