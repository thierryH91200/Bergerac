import AppKit


// MARK: NSTableViewDataSource
extension ImportWindowController:  NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allData.count
    }
}

// MARK: NSTableViewDelegate
extension ImportWindowController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                
        guard let identifier = tableColumn?.identifier else { return nil }
        guard let col = Int(identifier.rawValue) else { return nil }
        if row  >= allData.count {
            return nil
        }
        let rowData = allData[row ]
        
        if rowData.count > col {
            let cell = cellView(tableColumn: tableColumn, string: rowData[col])
            return cell
        } else {
            return nil
        }
    }
    
    func cellView(tableColumn: NSTableColumn?, string: String ) -> NSTableCellView {
        
        let frameRect = NSRect(x: 0, y: 0, width: (tableColumn?.width)!, height: 22)
        let cell = NSTableCellView(frame: frameRect)
        cell.identifier = (tableColumn?.identifier)!
        let indexCol = Int((tableColumn?.identifier.rawValue)!)
        
        let textField = NSTextField(frame: cell.frame)
        textField.stringValue = string
        textField.isEditable = false
        textField.isBordered = false
        textField.isBezeled = false
        textField.sizeToFit()
        
        let items = menuHeader.items
        
        for i in 0 ..< items.count {
            let rep = items[i].representedObject as!  [HeaderColumnForMenu]
            let index = rep.firstIndex { $0.numCol == indexCol }
            if index != nil {
                let newItem = rep[index!]
                if newItem.numMenu != 0 {
                    textField.textColor = .blue
                    break
                }
            }
        }
        
        textField.backgroundColor = NSColor.controlColor
        textField.sizeToFit()
        cell.addSubview(textField)
        
        return cell
    }
}

// MARK: TTFormatViewControllerDelegate
extension ImportWindowController: TTFormatViewControllerDelegate {
    
    func configurationChanged(for formatViewController: TTFormatViewController?) {
        
        guard url != "" else { return }
        
        let stream = InputStream(fileAtPath: self.url)
        let config = formatViewController?.config
        
        let delimiter = (config?.delimiter)!
        let encoding = (config?.encoding)!
        
        let configuration = CSV.Configuration(delimiter: delimiter, encoding: encoding)
        let parser = CSV.Parser(inputStream: stream!, configuration: configuration)
        parser.delegate = self
        do {
            try parser.parse()
        } catch {
            print("Error fetching data from CoreData")
        }
    }
    
}
