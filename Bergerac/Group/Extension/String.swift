//
//  String.swift
//  Bergerac
//
//  Created by thierryH24 on 09/05/2021.
//  Copyright © 2021 thierry hentic. All rights reserved.
//

import Foundation


extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension String {
    func removeFormatAmount() -> Double {
        var format = self
        format = format.replacingOccurrences(of: "(", with: "")     // Excel
        format = format.replacingOccurrences(of: ")", with: "")     // Excel
        format = format.replacingOccurrences(of: ",", with: ".")
        format = format.replacingOccurrences(of: " ", with: "")

            // https://stackoverflow.com/questions/5105053/iphone-uilabel-non-breaking-space
        format = format.replacingOccurrences(of: "\u{00a0}", with: "")
        
        let cur = Locale.current.currencySymbol
        format = format.replacingOccurrences(of: cur!, with: "")
        
        let amount = Double(format) ?? 0.0
        return amount
     }
}

extension String {

  static var FilePrefix = "file://"

  subscript (i: Int) -> Character {
    return self[index(startIndex, offsetBy: i)]
  }

//  public var isMarkdown: Bool {
//    return hasSuffix(".md") || hasSuffix(".markdown")
//  }

//  public var isBaseFile: Bool {
//    return self == "file:///" || self == "file://"
//  }

//  public var isWebLink: Bool {
//    return contains("http")
//  }

  public var removingPercentEncoding: String {
    return self.removingPercentEncoding ?? self
  }

//  public var isWhiteSpace: Bool {
//    return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//  }

  /// Decode URL and convert ~ to Home directory
  public var decoded: String? {
    let fileManager = FileManager.default

    return self
      .removingPercentEncoding?
      .replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path)
  }

}




// https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
//extension StringProtocol {
//    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
//    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
//    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
//    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
//    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
//    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
//}
//extension LosslessStringConvertible {
//    var string: String { .init(self) }
//}
//extension BidirectionalCollection {
//    subscript(safe offset: Int) -> Element? {
//        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
//        return self[i]
//    }
//}


//Testing
//
//let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[safe: 10]   // "🇺🇸"
//test[11]   // "!"
//test[10...]   // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[10..<12]   // "🇺🇸!"
//test[10...12]   // "🇺🇸!!"
//test[...10]   // "Hello USA 🇺🇸"
//test[..<10]   // "Hello USA "
//test.first   // "H"
//test.last    // "!"
//
//// Subscripting the Substring
// test[...][...3]  // "Hell"
//
//// Note that they all return a Substring of the original String.
//// To create a new String from a substring
//test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
