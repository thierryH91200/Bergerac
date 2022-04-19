//
//  Transformable.swift
//  Bergerac
//
//  Created by thierryH24 on 28/10/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import AppKit


// 1. Subclass from `NSSecureUnarchiveFromDataTransformer`
@objc(NSColorValueTransformer)
final class ColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: ColorValueTransformer.self))

    // 2. Make sure `UIColor` is in the allowed class list.
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSColor.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = ColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

//@objc(CustomClassValueTransformer)
//final class CustomClassValueTransformer: NSSecureUnarchiveFromDataTransformer {
//
//    static let name = NSValueTransformerName(rawValue: String(describing: CustomClass.self))
//
//    // Make sure `CustomClass` is in the allowed class list,
//    // AND any other classes that are encoded in `CustomClass`
//    override static var allowedTopLevelClasses: [AnyClass] {
//        // for example... yours may look different
//        return [CustomClass.self, OtherClass.self, NSArray.self, NSValue.self]
//    }
//
//    /// Registers the transformer.
//    public static func register() {
//        let transformer = CustomClassValueTransformer()
//        ValueTransformer.setValueTransformer(transformer, forName: name)
//    }
//}
//

final class MyCustomObject: NSSecureCoding {
    func encode(with coder: NSCoder) {
    }
    
    init?(coder: NSCoder) {
    }
    
    static var supportsSecureCoding = true
}

