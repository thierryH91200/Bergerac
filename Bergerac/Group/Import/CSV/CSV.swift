//
//  CSV.swift
//  swift-csv
//
//  Created by Matthias Hochgatterer on 02/06/2017.
//  Copyright © 2017 Matthias Hochgatterer. All rights reserved.
//


import Foundation

public struct CSV {
    
    static let CarriageReturn: UnicodeScalar = "\r"
    static let LineFeed: UnicodeScalar = "\n"
    static let DoubleQuote: UnicodeScalar = "\""
    static let Nul: UnicodeScalar = UnicodeScalar(0)
    
    /// Writes data in CSV format into an output stream.
    /// The writer uses the line feed "\n" character for line breaks. (Even though [RFC 4180](https://tools.ietf.org/html/rfc4180) specifies CRLF as line break characters.)
    public class Writer {
        
        let outputStream: OutputStream
        let configuration: CSV.Configuration
        
        internal let illegalCharacterSet: CharacterSet
        internal var maxNumberOfWrittenFields: Int?
        internal var numberOfWrittenLines: Int = 0
        
        public init(outputStream: OutputStream, configuration: CSV.Configuration) {
            
            if outputStream.streamStatus == .notOpen {
                outputStream.open()
            }
            
            self.outputStream = outputStream
            self.configuration = configuration
            self.illegalCharacterSet = CharacterSet(charactersIn: "\(DoubleQuote)\(configuration.delimiter)\(CarriageReturn)\(LineFeed)")
        }
        
        /// Writes fields as a line to the output stream.
        public func writeLine(of fields: [String]) throws {
            if let count = self.maxNumberOfWrittenFields {
                if count != fields.count {
                    throw CSVError(description: "Invalid number of fields")
                }
            } else {
                maxNumberOfWrittenFields = fields.count
            }
            
            if numberOfWrittenLines > 0 {
                self.writeNewLineCharacter()
            }
            
            let escapedValues = fields.map({ self.escapedValue(for: $0) })
            let string = escapedValues.joined(separator: String(configuration.delimiter))
            self.writeString(string)
            
            numberOfWrittenLines += 1
        }
        
        internal func writeNewLineCharacter() {
            self.writeString(String(LineFeed))
        }
        
        internal func escapedValue(for field: String) -> String {
            if field.rangeOfCharacter(from: illegalCharacterSet) != nil {
                // A double quote must be preceded by another double quote
                let value = field.replacingOccurrences(of: String(DoubleQuote), with: "\"\"")
                // Quote fields containing illegal characters
                return "\"\(value)\""
            }
            
            return field
        }
        
        internal func writeString(_ string: String) {
            if let data = string.data(using: configuration.encoding) {
                data.withUnsafeBytes {
                bytes in
                    let buffer: UnsafePointer<UInt8> = bytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    self.outputStream.write(buffer, maxLength: bytes.count)
                }
            }
        }
    }
    
}

