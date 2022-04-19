import Foundation


public protocol ParserDelegate: AnyObject {
    
    /// Called when the parser begins parsing.
    func parserDidBeginDocument(_ parser: CSV.Parser)
    
    /// Called when the parser finished parsing without errors.
    func parserDidEndDocument(_ parser: CSV.Parser)
    
    /// Called when the parser begins parsing a line.
    func parser(_ parser: CSV.Parser, didBeginLineAt index: UInt)
    
    /// Called when the parser finished parsing a line.
    func parser(_ parser: CSV.Parser, didEndLineAt index: UInt)
    
    /// Called for every field in a line.
    func parser(_ parser: CSV.Parser, didReadFieldAt index: UInt, value: String)
}

public struct CSVError: Error {
    public let description: String
}

internal class BufferedByteReader {
    let inputStream: InputStream
    var isAtEnd = false
    var buffer = [UInt8]()
    var bufferIndex = 0
    
    init(inputStream: InputStream) {
        if inputStream.streamStatus == .notOpen {
            inputStream.open()
        }
        self.inputStream = inputStream
    }
    
    /// - returns: The next character and removes it from the stream after it has been returned, or nil if the stream is at the end.
    func pop() -> UInt8? {
        guard let byte = self.peek() else {
            isAtEnd = true
            return nil
        }
        bufferIndex += 1
        return byte
    }
    
    /// - Returns: The character at `index`, or nil if the stream is at the end.
    func peek(at index: Int = 0) -> UInt8? {
        let peekIndex = bufferIndex + index
        guard peekIndex < buffer.count else {
            guard read(100) > 0 else {
                // end of file or error
                return nil
            }
            return self.peek(at: index)
        }
        return buffer[peekIndex]
    }
    
    // MARK: - Private
    private func read(_ amount: Int) -> Int {
        if bufferIndex > 0 {
            buffer.removeFirst(bufferIndex)
            bufferIndex = 0
        }
        var temp = [UInt8](repeating: 0, count: amount)
        let length = inputStream.read(&temp, maxLength: temp.count)
        if length > 0 {
            buffer.append(contentsOf: temp[0 ..< length])
        }
        return length
    }
}

extension String.Encoding {
    /// Unicode text data may start with a [byte order mark](https://en.wikipedia.org/wiki/Byte_order_mark) to specify the encoding and endianess.
    struct BOM {
        let encoding: String.Encoding
        init?(bom0: UInt8, bom1: UInt8, bom2: UInt8, bom3: UInt8) {
            switch (bom0, bom1, bom2, bom3) {
            case (0xEF, 0xBB, 0xBF, _):
                self.encoding = .utf8
            case (0xFE, 0xFF, _, _):
                self.encoding = .utf16BigEndian
            case (0xFF, 0xFE, _, _):
                self.encoding = .utf16LittleEndian
            case (0x00, 0x00, 0xFE, 0xFF):
                self.encoding = .utf32BigEndian
            case (0xFF, 0xFE, 0x00, 0x00):
                self.encoding = .utf32LittleEndian
            default:
                return nil
            }
        }
        
        var length: Int {
            switch self.encoding {
            case String.Encoding.utf8:
                return 3
            case String.Encoding.utf16BigEndian, String.Encoding.utf16LittleEndian:
                return 2
            case String.Encoding.utf32BigEndian, String.Encoding.utf32LittleEndian:
                return 4
            default:
                return 0
            }
        }
    }
}

