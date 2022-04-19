//
//  NSPredicateEditorRowTemplate.swift
//  KSPredicateEditorSwift
//
//  Created by thierryH24 on 28/11/2018.
//  Copyright © 2018 thierryH24. All rights reserved.
//

import AppKit


// MARK: - Rubrique

// func init()
// func init(leftExpressions: [NSExpression])
// func predicate
final class RowTemplateRelationshipRubrique: NSPredicateEditorRowTemplate {

    var entityRubric = [EntityRubric]()
    var arrayRub = [NSExpression]()

    override init() {
        super.init()
    }
    
    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipRubrique.boolOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        self.arrayRub.removeAll()
        self.entityRubric = Rubric.shared.getAllDatas()
        
        for i in 0..<entityRubric.count {
            arrayRub.append(NSExpression(forKeyPath: entityRubric[i].name!))
        }

        super.init(leftExpressions: leftExpressions ,
                   rightExpressions: arrayRub ,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: RowTemplateRelationshipRubrique.option)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name %@ \"%@\").@count > 0", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

// MARK: - Category
// func init()
// func init(leftExpressions: [NSExpression])
// func predicate
final class RowTemplateRelationshipCategory: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }
    
    init(leftExpressions: [NSExpression]) {
        
        var operatorsNSNumber: [NSNumber] = []

        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipCategory.stringOperators
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: RowTemplateRelationshipCategory.option)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.name %@ %@).@count > 0", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

// MARK: - Status
// func init()
// func (leftExpressions: [NSExpression], leftEntity : String)
// func predicate
final class RowTemplateRelationshipStatus: NSPredicateEditorRowTemplate {
    
    static var entity = ""
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression], leftEntity : String) {
        RowTemplateRelationshipStatus.entity = leftEntity

        var operatorsNSNumber: [NSNumber] = []
        var arrStatus = [NSExpression]()

        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipStatus.boolOperators
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        let planifie = Localizations.Statut.Planifie
        let engaged = Localizations.Statut.Engaged
        let realise = Localizations.Statut.Realise
        let status = [planifie, engaged, realise]
        
        for statut in status {
            arrStatus.append( NSExpression(forKeyPath: statut))
        }

        super.init(leftExpressions: leftExpressions ,
                   rightExpressions: arrStatus,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: RowTemplateRelationshipStatus.option)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        let right = String(format: "%@", predicate.rightExpression)
        let findRight = Statut.shared.findStatut(statut: right)
        
        let predicateFormat  = String(format : "%@ %@ %d", RowTemplateRelationshipStatus.entity , operatorName, findRight)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

// MARK: - Libelle
// func init()
// func init(leftExpressions: [NSExpression])
// func predicate
final class RowTemplateRelationshipLibelle: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression]) {
        
        var operatorsNSNumber: [NSNumber] = []

        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipLibelle.stringOperators
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        let option = RowTemplateRelationshipLibelle.option
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: option)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        let predicateFormat = String(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.libelle %@ %@).@count > 0", operatorName, predicate.rightExpression)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
}

// MARK: - Montant
// func init()
// func init(leftExpressions: [NSExpression])
// func predicate
final class RowTemplateRelationshipMontant: NSPredicateEditorRowTemplate {
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression]) {
        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipMontant.numberOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .doubleAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate {
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let rightExpression = predicate.rightExpression
        
        let predicateFormat  = String(format : "SUBQUERY(sousOperations, $sousOperation, $sousOperation.amount %@ %@).@count > 0", operatorName, rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        
        return newPredicate
    }
}

// MARK: - Mode
final class RowTemplateRelationshipMode: NSPredicateEditorRowTemplate {
    
    static var entity = ""

    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression], leftEntity : String) {
        
        var arrayMode = [NSExpression]()

        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipMode.boolOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        let modesPaiement = PaymentMode.shared.getAllDatas()
        for modePaiement in modesPaiement
        {
            arrayMode.append( NSExpression(forKeyPath: modePaiement.name!))
        }

        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressions: arrayMode ,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: RowTemplateRelationshipMode.option)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let predicateFormat  = String(format : "paymentMode.name %@ \"%@\"", operatorName, predicate.rightExpression)
        let newPredicate = NSPredicate(format: predicateFormat)
        
        return newPredicate
    }
}

// MARK: - Date
// func init()
// func init(leftExpressions: [NSExpression], leftEntity : String)
// func predicate

final class RowTemplateRelationshipDate: NSPredicateEditorRowTemplate {
    
    static var entity = ""
    
    override init() {
        super.init()
    }

    init(leftExpressions: [NSExpression], leftEntity : String) {
        RowTemplateRelationshipDate.entity = leftEntity
        let operators: [NSComparisonPredicate.Operator] = RowTemplateRelationshipMontant.dateOperators
        var operatorsNSNumber: [NSNumber] = []
        for o in operators { operatorsNSNumber.append( NSNumber(value: o.rawValue) ) }
        
        super.init(leftExpressions: leftExpressions ,
                   rightExpressionAttributeType: .dateAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func predicate(withSubpredicates subpredicates: [NSPredicate]?) -> NSPredicate{
        
        let predicate = super.predicate(withSubpredicates: subpredicates) as! NSComparisonPredicate
        
        let operatorType = predicate.predicateOperatorType
        let operatorName = findOperatorType(operatorType: operatorType)
        
        let rightExpression = predicate.rightExpression.description
        let beginOfSentence = rightExpression.firstIndex(of: "(")!
        let endOfSentence = rightExpression.firstIndex(of: ",")!
        
        let sentence = TimeInterval(rightExpression[rightExpression.index(after: beginOfSentence)..<endOfSentence])
        
        let date = Date(timeIntervalSinceReferenceDate:  sentence!).noon
        let timeInterval = date.timeIntervalSinceReferenceDate
        let predicateFormat = String(format : "%@ %@ CAST(%.2f, 'NSDate')", RowTemplateRelationshipDate.entity , operatorName, timeInterval)
        
        let newPredicate = NSPredicate(format: predicateFormat)
        return newPredicate
    }
    
}

