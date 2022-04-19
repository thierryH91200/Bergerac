    //
    //  SchedulersSaisieControllerDelegate.swift
    //  Bergerac
    //
    //  Created by thierry hentic on 07/03/2020.
    //  Copyright © 2020 thierry hentic. All rights reserved.
    //

import AppKit
import SwiftDate


extension SchedulersSaisieController: SchedulersSaisieDelegate {
    
    func editionData(_ quake: EntitySchedule) {
        edition = true
        modeOperation.title = Localizations.Transaction.ModeEdition
        modeOperation.layer?.backgroundColor = NSColor.green.cgColor
        
        modeOperation2.title = Localizations.Transaction.ModeEdition
        modeOperation2.layer?.backgroundColor = NSColor.green.cgColor
        
        entitySchedule = quake
        
        libelle.stringValue = entitySchedule?.libelle ?? ""
        
        dateValeur.dateValue = (entitySchedule?.dateValeur)!
        dateDebut.dateValue = (entitySchedule?.dateDebut)!
        dateFin.dateValue = (entitySchedule?.dateFin ?? Date())
        occurence.intValue = Int32((entitySchedule?.occurence)!)
        frequence.intValue = Int32((entitySchedule?.frequence)!)
        popUpFrequence.selectItem(at: Int(entitySchedule?.typeFrequence ?? 0))
        
        let rubric = popUpRubrique.itemTitle(at: 0)
        popUpRubrique.selectItem(withTitle: (entitySchedule?.category?.rubric?.name ?? rubric)!)
        if popUpRubrique.indexOfSelectedItem == -1 {
            popUpRubrique.selectItem(at: 0)
        }
        
        loadCategory()
        popUpCategorie.selectItem(withTitle: (entitySchedule?.category?.name ?? "")!)
        if popUpCategorie.indexOfSelectedItem == -1 {
            popUpCategorie.selectItem(at: 0)
        }
        
        let mode = popUpModePaiement.itemTitle(at: 0)
        popUpModePaiement.selectItem(withTitle: (entitySchedule?.paymentMode?.name ?? mode)!)
        
        let valeurMontant = entitySchedule?.amount ?? 0.0
        montant.textColor = valeurMontant < 0 ? NSColor.red : NSColor.green
        montant.doubleValue = abs(valeurMontant)
        signeMontant.state = valeurMontant < 0 ? .on : .off
        
        popUpTransfert.selectItem(withTitle: entitySchedule?.compteLie?.initAccount?.codeAccount ?? "(no transfert)")
    }
    
    func razData()
    {
        entityPreference = Preference.shared.getAllDatas()
        
        edition = false
        modeOperation.title = Localizations.Transaction.ModeCreation
        modeOperation.layer?.backgroundColor = NSColor.orange.cgColor
        
        modeOperation2.title = Localizations.Transaction.ModeCreation
        modeOperation2.layer?.backgroundColor = NSColor.orange.cgColor
        
        account.stringValue = (currentAccount?.name)!
        name.stringValue = (currentAccount?.identity?.name)!
        surname.stringValue = (currentAccount?.identity?.surName)!
        number.stringValue = (currentAccount?.initAccount?.codeAccount)!
        
        loadCompte()
        popUpTransfert.itemTitle(at: 0)
        
        loadRubrique()
        popUpRubrique.selectItem(withTitle: (entityPreference?.category?.rubric?.name)!)
        
        loadCategory()
        popUpCategorie.selectItem(withTitle: (entityPreference?.category?.name)!)
        
        loadModePaiement()
        popUpModePaiement.selectItem(withTitle: (entityPreference?.paymentMode?.name)!)
        
        libelle.stringValue = ""
        
        popUpFrequence.selectItem(at: 2)
        dateDebut.dateValue = Date()
        dateFin.dateValue = Date() + 12.months
        dateValeur.dateValue = Date()
        frequence.intValue = 1
        occurence.intValue = 12
        
        montant.doubleValue = 0.0
        montant.textColor = NSColor.systemGreen
        signeMontant.state = entityPreference?.signe == true ? .on : .off
    }

}

