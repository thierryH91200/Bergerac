import Foundation


extension CSV {
    
    public class Parser {
        
        public weak var delegate: ParserDelegate?
        public let configuration: CSV.Configuration
        public var trimsWhitespaces: Bool = false
        
        // Reference to the file stream
        private let inputStream: InputStream
        
        // The buffer for field values
        private var fieldBuffer = [UInt8]()
        
        // The current row index
        private var row: UInt = 0
        
        // The current column index
        private var column: UInt = 0
        
        // Flag to know if the parser was cancelled.
        private var cancelled: Bool = false
        
        private enum State {
            case beginningOfDocument
            case endOfDocument
            case beginningOfLine
            case endOfLine
            case inField
            case inQuotedField
            case maybeEndOfQuotedField
            case endOfField
        }
        
        // The current parser state
        private var state: State = .beginningOfDocument {
            didSet {
                if oldValue == .beginningOfDocument {
                    delegate?.parserDidBeginDocument(self)
                }
                
                switch state {
                case .endOfDocument:
                    delegate?.parserDidEndDocument(self)
                case .beginningOfLine:
                    delegate?.parser(self, didBeginLineAt: row)
                case .endOfLine:
                    delegate?.parser(self, didEndLineAt: row)
                    column = 0
                    row += 1
                case .endOfField:
                    let data = Data( fieldBuffer)
                    let value: String
                    if let string = String(data: data, encoding: configuration.encoding) { // Try to decode using the specified encoding
                        value = string
                    } else {
                        value = String(cString: fieldBuffer + [0]) // cString requires '\0' at the end
                    }
                    fieldBuffer.removeAll()
                    
                    if !value.isEmpty && self.trimsWhitespaces {
                        let trimmed = value.trimmingCharacters(in: CharacterSet.whitespaces)
                        delegate?.parser(self, didReadFieldAt: column, value: trimmed)
                    } else {
                        delegate?.parser(self, didReadFieldAt: column, value: value)
                    }
                    
                    column += 1
                default:
                    break
                }
            }
        }
        
        /// Initializes the parser with an url.
        ///
        /// - Paramter url: An url referencing a CSV file.
        public convenience init?(url: URL, configuration: CSV.Configuration) {
            guard let inputStream = InputStream(url: url) else {
                return nil
            }
            
            self.init(inputStream: inputStream, configuration: configuration)
        }
        
        /// Initializes the parser with a string.
        ///
        /// - Paramter string: A CSV string.
        public convenience init(string: String, configuration: CSV.Configuration) {
            self.init(data: string.data(using: .utf8)!, configuration: configuration)
        }
        
        /// Initializes the parser with data.
        ///
        /// - Paramter data: Data represeting CSV content.
        public convenience init(data: Data, configuration: CSV.Configuration) {
            self.init(inputStream: InputStream(data: data), configuration: configuration)
        }
        
        /// Initializes the parser with an input stream.
        ///
        /// - Paramter inputStream: An input stream of CSV data.
        public init(inputStream: InputStream, configuration: CSV.Configuration = CSV.Configuration(delimiter: ",")) {
            self.inputStream = inputStream
            self.configuration = configuration
        }
        
        /// Cancels the parser.
        public func cancel() {
            self.cancelled = true
        }
        
        /// Starts parsing the CSV data. Calling this method does nothing if the parser already finished parsing the data.
        ///
        /// - Throws: An error if the data doesn't conform to [RFC 4180](https://tools.ietf.org/html/rfc4180).
        public func parse() throws {
            
            guard self.state != .endOfDocument && !cancelled else {
                return
            }
            
            let reader = BufferedByteReader(inputStream: inputStream)
            
            // Consume bom if available
            if let bom0 = reader.peek(at: 0), let bom1 = reader.peek(at: 1), let bom2 = reader.peek(at: 2), let bom3 = reader.peek(at: 3) {
                if let bom = String.Encoding.BOM(bom0: bom0, bom1: bom1, bom2: bom2, bom3: bom3) {
                    for _ in 0 ..< bom.length {
                        _ = reader.pop()
                    }
                }
            }
            
            while !reader.isAtEnd {
                while let char = reader.pop(), !cancelled {
                    let scalar = UnicodeScalar(char)
                    
                    // If we are at the begin of the data and there is a new character, we transition to the beginning of the line
                    if state == .beginningOfDocument {
                        state = .beginningOfLine
                    }
                    
                    // If we are at the end of the line and there is a new character, we transition to the beginning of the line
                    if state == .endOfLine {
                        state = .beginningOfLine
                    }
                    
                    switch scalar {
                    case self.configuration.delimiter:
                        switch state {
                        case .beginningOfLine:
                            state = .endOfField
                        case .inField:
                            state = .endOfField
                        case .inQuotedField:
                            fieldBuffer.append(char)
                        case .maybeEndOfQuotedField:
                            state = .endOfField
                        case .endOfField:
                            state = .endOfField
                        default:
                            assertionFailure("Invalid state")
                        }
                    case CSV.CarriageReturn:
                        switch state {
                        case .beginningOfLine:
                            fallthrough
                        case .inField:
                            fallthrough
                        case .maybeEndOfQuotedField:
                            fallthrough
                        case .endOfField:
                            
                            // If there is a \n after the carriage return, we read it.
                            // But that's optional
                            if let next = reader.peek(), UnicodeScalar(next) == UnicodeScalar(0) {
                                _ = reader.pop()
                            }
                            if let next = reader.peek(), UnicodeScalar(next) == "\n" {
                                _ = reader.pop()
                            }
                            
                            state = .endOfField
                            state = .endOfLine
                        case .inQuotedField:
                            fieldBuffer.append(char)
                        default:
                            assertionFailure("Invalid state")
                        }
                    case CSV.LineFeed:
                        switch state {
                        case .beginningOfLine:
                            fallthrough
                        case .inField:
                            fallthrough
                        case .maybeEndOfQuotedField:
                            fallthrough
                        case .endOfField:
                            state = .endOfField
                            state = .endOfLine
                        case .inQuotedField:
                            fieldBuffer.append(char)
                        default:
                            assertionFailure("Invalid state")
                        }
                    case CSV.DoubleQuote:
                        switch state {
                        case .beginningOfLine:
                            state = .inQuotedField
                        case .endOfField:
                            state = .inQuotedField
                        case .maybeEndOfQuotedField:
                            fieldBuffer.append(char)
                            state = .inQuotedField
                        case .inField:
                            // Ignore error
                            fieldBuffer.append(char)
                        case .inQuotedField:
                            state = .maybeEndOfQuotedField
                        default:
                            assertionFailure("Invalid state")
                        }
                    case CSV.Nul:
                        // Nul characters happen when characters are made up of more than 1 byte
                        switch state {
                        case .inField:
                            fallthrough
                        case .inQuotedField:
                            if fieldBuffer.isEmpty == false {
                                // Append to any existing character
                                fieldBuffer.append(char)
                            }
                        default:
                            break
                        }
                    default: // Any other characters
                        switch state {
                        case .beginningOfLine:
                            fieldBuffer.append(char)
                            state = .inField
                        case .endOfField:
                            fieldBuffer.append(char)
                            state = .inField
                        case .maybeEndOfQuotedField:
                            // Skip values outside of quoted fields
                            break
                        case .inField:
                            fieldBuffer.append(char)
                        case .inQuotedField:
                            fieldBuffer.append(char)
                        default:
                            assertionFailure("Invalid state")
                        }
                    }
                }
                
                if cancelled {
                    return
                }
                
                // Transition to the correct state at the end of the document
                switch state {
                case .beginningOfDocument:
                    // There was no data at all
                    break
                case .endOfDocument:
                    assertionFailure("Invalid state")
                case .beginningOfLine:
                    break
                case .endOfLine:
                    break
                case .endOfField:
                    // Rows must not end with the delimieter
                    // Therefore we there must be a new field before the end
                    state = .inField
                    state = .endOfField
                    state = .endOfLine
                case .inField:
                    state = .endOfField
                    state = .endOfLine
                case .inQuotedField:
                    throw CSVError(description: "Unexpected end of quoted field")
                case .maybeEndOfQuotedField:
                    state = .endOfField
                    state = .endOfLine
                }
                
                // Now we are at the end
                state = .endOfDocument
            }
        }
    }
    
}
