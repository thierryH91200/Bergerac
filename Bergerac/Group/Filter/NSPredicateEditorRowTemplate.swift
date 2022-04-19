//
//  NSPredicateEditorRowTemplate.swift
//  KSPredicateEditorSwift
//
//  Created by thierryH24 on 28/11/2018.
//  Copyright © 2018 thierryH24. All rights reserved.
//

import AppKit

extension NSPredicateEditorRowTemplate {
    
    static let numberOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .greaterThan, .greaterThanOrEqualTo, .lessThan, .lessThanOrEqualTo]
    static let stringOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .beginsWith, .endsWith, .matches, .like,.contains]
    static let boolOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]
    static let dateOperators:[NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .greaterThan, .lessThan]
    static let option = Int(NSComparisonPredicate.Options.caseInsensitive.rawValue)  // | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)
//    static let option = Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)


    convenience init( compoundTypes: [NSCompoundPredicate.LogicalType] ) {
        
        let compoundTypesNSNumber = (0..<compoundTypes.count).map { (i) -> NSNumber in
            return NSNumber(value: compoundTypes[i].rawValue)
        }
        self.init( compoundTypes: compoundTypesNSNumber )
    }
    
    convenience init? (forKeysPath keyPaths:String, ofType type:NSAttributeType, andPrefix prefix:String=""){
        var templateOperator = [NSNumber]()
        
        //Setup depending on the type
        switch type {
        case .decimalAttributeType, .doubleAttributeType, .floatAttributeType, .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            templateOperator = NSPredicateEditorRowTemplate.numberOperators.map{NSNumber(value: $0.rawValue)}
        case .dateAttributeType:
            templateOperator = NSPredicateEditorRowTemplate.dateOperators.map{NSNumber(value: $0.rawValue)}
        case .stringAttributeType:
            templateOperator = NSPredicateEditorRowTemplate.stringOperators.map{NSNumber(value: $0.rawValue)}
        case .booleanAttributeType:
            templateOperator = NSPredicateEditorRowTemplate.boolOperators.map{NSNumber(value: $0.rawValue)}
        default:
            print("Attribute type: \(type) not implemented.")
            return nil
        }
        //Generic values
        let leftExp = NSExpression(forKeyPath: prefix + keyPaths)
        let options = type == .stringAttributeType ? (Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)) : 0
        self.init( leftExpressions: [leftExp],
                   rightExpressionAttributeType: type,
                   modifier: .direct,
                   operators: templateOperator,
                   options: options )
    }

    // Constant values
    convenience init( forKeyPath keyPath: String, withValues values: [Any] , operators: [NSComparisonPredicate.Operator]) {
        
        let keyPaths: [NSExpression] = [NSExpression(forKeyPath: keyPath)]
        var constantValues: [NSExpression] = []
        for value in values {
            constantValues.append( NSExpression(forConstantValue: value) )
        }
        
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: keyPaths,
                   rightExpressions: constantValues,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue))
    }
    
    // MARK: String
    convenience init( stringCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .stringAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)) 
    }
    
    // MARK: Int
    convenience init( IntCompareForKeyPaths keyPaths: [String], operators: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .integer16AttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    // MARK: Date
    convenience init( DateCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .dateAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: 0 )
    }
    
    // MARK: Bool
    convenience init( BoolCompareForKeyPaths keyPaths: [String] , operators: [NSComparisonPredicate.Operator]) {
        
        let leftExpressions = (0..<keyPaths.count).map { (i) -> NSExpression in
            return NSExpression(forKeyPath: keyPaths[i])
        }
        let operatorsNSNumber = (0..<operators.count).map { (i) -> NSNumber in
            return NSNumber(value: operators[i].rawValue)
        }
        
        let option = Int(NSComparisonPredicate.Options.caseInsensitive.rawValue | NSComparisonPredicate.Options.diacriticInsensitive.rawValue)
        self.init( leftExpressions: leftExpressions,
                   rightExpressionAttributeType: .booleanAttributeType,
                   modifier: .direct,
                   operators: operatorsNSNumber,
                   options: option )
    }
    
    func findOperatorType(operatorType : NSComparisonPredicate.Operator) -> String {
        
        var operatorName = ""
        switch (operatorType) {
        case .equalTo:
            operatorName = "=="
        case .beginsWith:
            operatorName = "BEGINSWITH[cd]"
        case .endsWith:
            operatorName = "ENDSWITH[cd]"
        case .contains:
            operatorName = "CONTAINS[cd]"
        case .lessThan:
            operatorName = "<"
        case .lessThanOrEqualTo:
            operatorName = "<="
        case .greaterThan:
            operatorName = ">"
        case .greaterThanOrEqualTo:
            operatorName = ">="
        case .notEqualTo:
            operatorName = "!="
        case .matches:
            operatorName = "MATCHES"
        case .like:
            operatorName = "LIKE"
        case .in:
            operatorName = "'in'"
        case .customSelector:
            operatorName = "CONTAINS"
        case .between:
            operatorName = "BETWEEN"
        @unknown default:
            operatorName = "CONTAINS"
        }
        return operatorName
    }
}

