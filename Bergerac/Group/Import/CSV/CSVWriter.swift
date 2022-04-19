import AppKit

final class CSVWriter: NSObject {
    
    var quoteOrColumnSeparator: CharacterSet?
    var errorCode4 = ""
    
    var dataArray = [String]()
    var config: CSV.Configuration?
    
    init(dataArray: [String], columnsOrder: [String], configuration config: CSV.Configuration) {
        super.init()
        
        self.dataArray = dataArray
        self.config = config
        errorCode4 = "Try to specifiy another encoding to export data"
    }
}
