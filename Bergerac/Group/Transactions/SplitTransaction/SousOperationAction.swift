//
//  SousOperationAction.swift
//  Bergerac
//
//  Created by thierry hentic on 18/09/2019.
//  Copyright © 2019 thierryH24. All rights reserved.
//

import AppKit

extension SousOperationModalWindowController  {
    
    @IBAction func actionSigne(_ sender: NSButton) {
        
        if sender.state == .on {
            self.textFieldAmount.textColor = NSColor.red
        } else {
            self.textFieldAmount.textColor = NSColor.green
        }
    }

    @IBAction func didTapCancelButton(_ sender: NSButton) {
        
        self.entitySousOperation =  nil
        window?.sheetParent?.endSheet(window!, returnCode: .cancel)
        self.window!.close()
    }
    
    @IBAction func didTapDoneButton(_ sender: NSButton) {
        
        /// Montant
        let amount = textFieldAmount.doubleValue
        let signe = amountSign.state.rawValue
        entitySousOperation?.amount = signe == 0 ? amount : -amount
        
        /// Libelle
        entitySousOperation?.libelle = textFieldLibelle.stringValue
        
        /// Rubrique + Category
        let selectRub = comboBoxRubrique.indexOfSelectedItem
        var entityCategories = entityRubric[selectRub].category?.allObjects as! [EntityCategory]
        entityCategories = entityCategories.sorted { $0.name! < $1.name! }

        let selectCat = comboBoxCategory.indexOfSelectedItem
        let entityCategory = entityCategories[selectCat]
        entitySousOperation?.category = entityCategory

        window?.sheetParent?.endSheet(window!, returnCode: .OK)
        self.window!.close()
    }
    
}
