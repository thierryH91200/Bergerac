import AppKit

extension ImportWindowController: ParserDelegate {
    
    func parserDidBeginDocument(_ parser: CSV.Parser) {
        allData.removeAll()
        headerData.removeAll()
        dataRow.removeAll()
        nColumns = 0
    }
    
    func parser(_ parser: CSV.Parser, didBeginLineAt index: UInt) {
        line = Int(index)
        dataLine.removeAll()
    }
    
    func parser(_ parser: CSV.Parser, didReadFieldAt index: UInt, value: String) {
        
        dataRow.append(value)
        
        let statusBar = self.statusBarFormatViewController
        let conf = statusBar?.config
        let isFirstRowAsHeader = conf?.isFirstRowAsHeader
//        print( "isFirstRowAsHeader : ", isFirstRowAsHeader! )
        if isFirstRowAsHeader! == true && line == 0 {
            headerData.append(value)
        } else {
            dataLine.append(value)
        }
    }
    
    func parser(_ parser: CSV.Parser, didEndLineAt index: UInt) {
        if dataLine.count > nColumns {
            nColumns = dataLine.count
        }
        
        allDataRow.append( dataLine)
        
        let isFirstRowAsHeader = statusBarFormatViewController?.config.isFirstRowAsHeader
        if !(isFirstRowAsHeader == true && line == 0) {
            allData.append(dataLine)
        }
    }
    
    func parserDidEndDocument(_ parser: CSV.Parser) {
        while let col = anTableView?.tableColumns.last {
            anTableView?.removeTableColumn(col)
        }

        nColumns += 1
        for i in 0 ..< nColumns {
            let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier( "\(i)"))
            col.sizeToFit()
            col.headerCell.alignment = .center
            col.resizingMask = [.userResizingMask, .autoresizingMask]
            
            let isFirstRowAsHeader = statusBarFormatViewController?.config.isFirstRowAsHeader
            if isFirstRowAsHeader == true && headerData.count > i {
                //                if i > 0 {
                col.headerCell.title = headerData[i]
                //                } else {
                //                    col.headerCell.title = "Num" + String(i)
                //                }
            }
            anTableView?.addTableColumn(col)
        }
        anTableView?.reloadData()
        anTableView.sizeToFit()
    }

}
