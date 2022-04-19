//
//  SousOperationComboBoxDelegate.swift
//  Bergerac
//
//  Created by thierry hentic on 09/09/2019.
//  Copyright © 2019 thierryH24. All rights reserved.
//

import AppKit

extension SousOperationModalWindowController : NSComboBoxDelegate {
    
    /// Informs the delegate that the pop-up list selection has finished changing.
    func comboBoxSelectionDidChange(_ notification: Notification) {
        
        let comboBox = (notification.object as? NSComboBox)!
        let selectRub = comboBoxRubrique.indexOfSelectedItem
        guard selectRub != -1 else { return }
        
        if comboBox == self.comboBoxRubrique
        {
            entityCategories = entityRubric[selectRub].category?.allObjects as! [EntityCategory]
            entityCategories = entityCategories.sorted { $0.name! < $1.name! }
            
            arrayCat.removeAll()
            arrayCat = (0..<entityCategories.count).map { i -> String in
                return entityCategories[i].name!
            }
            
            comboBoxCategory.removeAllItems()
            comboBoxCategory.addItems(withObjectValues: arrayCat)

            comboBoxCategory.selectItem(at: 0)
        }
    }

}
