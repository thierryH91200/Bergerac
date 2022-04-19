import Foundation

extension CSV {
    /// A configuration specifies the delimiter and encoding for parsing CSV data.
    public struct Configuration {
        
        var delimiter: UnicodeScalar
        var encoding = String.Encoding(rawValue: 4)
        var quoteCharacter = "\""
        var escapeCharacter = "\""
        var decimalMark = "."
        var isFirstRowAsHeader = true
        var isReverseSignAmountCheckBbox = false
        
        public init() {
            encoding = .utf8
            quoteCharacter = "\""
            escapeCharacter = "\""
            decimalMark = "."
            isFirstRowAsHeader = true
            isReverseSignAmountCheckBbox = false
            delimiter = ";"
        }
        
        /// Initializes a configuration with a delimiter and text encoding.
        public init(delimiter: UnicodeScalar, encoding: String.Encoding = .utf8) {
            self.delimiter = delimiter
            self.encoding = encoding
        }

        
        /// Returns a configuration by detecting the delimeter and text encoding from a file at an url.
        public static func detectConfiguration( url: URL) -> Configuration? {
            guard let stream = InputStream(url: url) else {
                return nil }
            
            return self.detectConfiguration(stream: stream)
        }
        
        /// Returns a configuration by detecting the delimeter and text encoding from the CSV input stream.
        public static func detectConfiguration( stream: InputStream) -> Configuration? {
            if stream.streamStatus == .notOpen {
                stream.open()
            }
            
            let maxLength = 400
            var buffer = [UInt8](repeating: 0, count: maxLength)
            let length = stream.read(&buffer, maxLength: buffer.count)
            if let error = stream.streamError {
                print(error)
                return nil
            }
            
            var encoding: String.Encoding = .utf8
            var string = ""
            
            if length > 4 {
                if let bom = String.Encoding.BOM(bom0: buffer[0], bom1: buffer[1], bom2: buffer[2], bom3: buffer[3]) {
                    encoding = bom.encoding
                    if bom.length > 0 {
                        buffer.removeFirst(bom.length)
                    }
                    if let decoded = String(bytes: buffer, encoding: encoding) {
                        string = decoded
                    }
                }
            }
            if string == "" {
                if let macOSRoman = String(bytes: buffer, encoding: .macOSRoman) {
                    string = macOSRoman
                    encoding = .macOSRoman
                    
                } else {
                    return nil
                }
            }
            
            let scanner = Scanner(string: string)
            
            var firstLine: NSString?
            scanner.scanUpToCharacters(from: CharacterSet.newlines, into: &firstLine)
            
            guard let header = firstLine else {
                return nil }
            
            return self.detectConfiguration(header as String, encoding: encoding)
        }
        
        /// Returns a configuration by detecting the delimeter and text encoding from a CSV string.
        public static func detectConfiguration(_ string: String, encoding: String.Encoding) -> Configuration {
            struct Delimiter {
                let scalar: UnicodeScalar
                let weight: Int
            }
            
            let delimiters = [",", ";", "\t"].map({ Delimiter(scalar: UnicodeScalar($0)!, weight: string.components(separatedBy: $0).count) })
            let winner = delimiters.sorted(by: {
            lhs, rhs in
                return lhs.weight > rhs.weight
            })
                .first!
            
            return Configuration(delimiter: winner.scalar, encoding: encoding)
        }
        
        static func supportedEncodings() -> [[Any]]? {
            return [["Unicode (UTF-8)", 0x4],
                    ["Western (Mac OS Roman)", 0x1e],
                    ["Western (Windows Latin 1)", 0xc],
                    ["Chinese (GBK)", 0x80000632],
                    ["Central European (ISO Latin 2)", 0x9],
                    ["Central European (Windows Latin 2)", 0xf],
                    ["Cyrillic (Windows)", 0xb],
                    ["Greek (Windows)", 0xd],
                    ["Turkish (Windows)", 0xe],
                    ["Japanese (EUC)", 0x3],
                    ["Japanese (Shift_JIS)", 0x8],
                    ["Japanese (ISO 2022-JP)", 0x15],
                    ["Unicode (UTF-16)", 0xa],
                    ["Unicode (UTF-16, Big Endian)", 0x90000100],
                    ["Unicode (UTF-16, Little Endian)", 0x94000100],
                    ["Unicode (UTF-32)", 0x8c000100],
                    ["Unicode (UTF-32, Big Endian)", 0x98000100],
                    ["Unicode (UTF-32, Little Endian)", 0x9c000100]]
        }
        
    }
    
}

