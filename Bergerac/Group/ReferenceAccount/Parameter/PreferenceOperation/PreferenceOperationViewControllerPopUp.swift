import AppKit

extension PreferenceOperationViewController : NSComboBoxDataSource {
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if comboBox == self.comboBoxRubrique
        {
            return entityRubrique.count
        }
        if comboBox == self.comboBoxCategory
        {
            let select = comboBoxRubrique.indexOfSelectedItem
            if select != -1 {
                let category = entityRubrique[select].category?.allObjects
                return (category?.count)!
            }
        }
        if comboBox == self.comboBoxMode
        {
            return entityMode.count
        }

        return 0 // never..........
    }
    
    // Returns the object that corresponds to the item at the specified index in the combo box
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if comboBox == self.comboBoxRubrique
        {
            return entityRubrique[index].name
        }
        if comboBox == self.comboBoxCategory
        {
            if index != -1 {
                let select = comboBoxRubrique.indexOfSelectedItem
                var entityCategory = entityRubrique[select].category?.allObjects as! [EntityCategory]
                entityCategory = entityCategory.sorted { $0.name! < $1.name! }
                return entityCategory[index].name
            }
        }
        if comboBox == self.comboBoxMode
        {
            return entityMode[index].name
        }
        return ""
    }
    
}

extension PreferenceOperationViewController : NSComboBoxDelegate {
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let comboBox = (notification.object as? NSComboBox)!
        let selectRub = comboBoxRubrique.indexOfSelectedItem
        guard selectRub != -1 else { return }
        
        let selectStatut = comboBoxStatut.indexOfSelectedItem
        guard selectStatut != -1 else { return }

        if comboBox == self.comboBoxRubrique
        {
            var entityCategory = entityRubrique[selectRub].category?.allObjects as! [EntityCategory]
            entityCategory = entityCategory.sorted { $0.name! < $1.name! }
            entityPreference?.category = entityCategory[0]
            
            comboBoxCategory.selectItem(at: 0)
        }
        
        if comboBox == self.comboBoxCategory
        {
            let selectCat = comboBoxCategory.indexOfSelectedItem
            var entityCategory = entityRubrique[selectRub].category?.allObjects as! [EntityCategory]
            entityCategory = entityCategory.sorted { $0.name! < $1.name! }
            entityPreference?.category = entityCategory[selectCat]
        }
        if comboBox == self.comboBoxStatut {
            entityPreference?.statut = Int16(selectStatut)
        }
        
        if comboBox == self.comboBoxMode {
            entityPreference?.paymentMode = entityMode[ comboBoxMode.indexOfSelectedItem]
        }

        NotificationCenter.send(.updateTransaction)

    }
    
}

