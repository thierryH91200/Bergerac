    //
    //  MyPrintView.swift
    //  Bergerac
    //
    //  Created by thierryH24 on 02/09/2018.
    //  Copyright © 2018 thierryH24. All rights reserved.
    //

import AppKit

final class MyPrintViewOutline: NSView
{
    weak var tableToPrint: NSOutlineView?
    
    var header = ""
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    var listFont = NSFont(name: "Helvetica", size: 10.0)
    var listFont1 = NSFont(name: "Helvetica", size: 10.0)
    
    var headerHeight: CGFloat = 0.0
    var footerHeight: CGFloat = 0.0
    var lineHeight: CGFloat = 0.0
    var rowHeight: CGFloat = 0.0
    var pageRect               = NSRect.zero
    var linesPerPage           = 0
    var currentPage            = 0
    
    var rightMargin: CGFloat = 20.0
    let bottomMargin: CGFloat =  0.0
    var leftMargin: CGFloat = 0
    var topMargin: CGFloat = 0
    
    var numberOfRows = 0
    var numberOfRowsByPage = 0
    
    let margin: CGFloat = 20
    
    var  widthQuotient: CGFloat = 0
    
    override  var printJobTitle: String {
        return "Liste Transactions"
    }
    
    init(tableView tableToPrint: NSOutlineView?, andHeader header: String?) {
            // Initialize with dummy frame
        super.init(frame: NSRect(x: 0, y: 0, width: 700, height: 700))
        
            //        let jobTitle = fileURL?.lastPathComponent ?? window.textView.printJobTitle
        
        self.tableToPrint = tableToPrint
        
        self.header = header!
        self.listFont = NSFont(name: "Helvetica", size: 10.0)
        
        self.lineHeight = listFont!.boundingRectForFont.size.height
        self.rowHeight = listFont!.capHeight * 2.5
        self.headerHeight = margin + rowHeight
        self.footerHeight = margin
        
        self.leftMargin = pageRect.origin.x + margin
        self.topMargin = pageRect.origin.y + headerHeight
        self.numberOfRows = tableToPrint!.numberOfRows
        
        self.attributes = [.font: listFont!]
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        // MARK: Pagination
    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        
        let printInfo = NSPrintOperation.current?.printInfo
        self.pageRect = (printInfo?.imageablePageBounds)!
        
        var newFrame = NSRect.zero
        newFrame.size = printInfo?.paperSize ?? CGSize.zero
        self.frame = newFrame
        
            // Number of lines per page
        self.linesPerPage = Int((pageRect.size.height - headerHeight - footerHeight) / rowHeight - CGFloat(1))
        
            // Number of full pages
        var noPages: Int = numberOfRows / self.linesPerPage
        
            // Rest of lines on last page
        if self.numberOfRows % self.linesPerPage > 0 {
            noPages += 1
        }
        range.pointee.location = 1
        range.pointee.length = noPages
        return true
    }
    
    override func rectForPage(_ page: Int) -> NSRect {
        currentPage = page - 1
        return pageRect
    }
    
        //    override var pageHeader: NSAttributedString
        //    {
        //        var paperWidth = textView.frame.width
        //
        //        if let printInfo = printPanelAccessoryController?.representedObject as? NSPrintInfo
        //        {
        //            paperWidth = printInfo.paperSize.width - printInfo.rightMargin
        //        }
        //
        //        let headerString = NSMutableAttributedString.init(string: "")
        //
        //        // Adds filename text aligned to center
        //        if printPanelAccessoryController?.showFileName == true
        //        {
        //            let titleParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        //            titleParagraphStyle.tabStops = [NSTextTab.init(textAlignment: .center, location: paperWidth / 2.0, options: [:])]
        //
        //            headerString.append(NSAttributedString(string: "\t" + jobTitle,
        //                                                   attributes: [.paragraphStyle: titleParagraphStyle]))
        //        }
        //
        //        // Adds print date text aligned to right
        //        if printPanelAccessoryController?.showDate == true
        //        {
        //            let dateParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        //            dateParagraphStyle.tabStops = [NSTextTab.init(textAlignment: .right, location: paperWidth, options: [:])]
        //
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateStyle = .short
        //            dateFormatter.timeStyle = .short
        //
        //            headerString.append(NSAttributedString(string: "\t" + dateFormatter.string(from: Date()),
        //                                                   attributes: [.paragraphStyle: dateParagraphStyle]))
        //        }
        //
        //        return headerString
        //    }
    
    
        //    override var pageHeader: NSAttributedString {
        //        return NSAttributedString(string: header)
        //    }
    
        // MARK: Drawing
    
        // Origin top left
    override var isFlipped: Bool {
        return true
    }
    
        // This is where the drawing takes place
    override func draw(_ dirtyRect: NSRect) {
        
        NSBezierPath.defaultLineWidth = 0.1
        
        var originalWidth: CGFloat = 0
        for column in tableToPrint!.tableColumns {
            originalWidth += column.width
        }
        self.widthQuotient = (pageRect.size.width - margin) / originalWidth
        
        let inset = (rowHeight - lineHeight - 1.0) / 2.0
        
            // Column titles
        var horizontalOffset: CGFloat = 0
        for column in tableToPrint!.tableColumns {
            
            if column.isHidden == true {
                continue
            }
            
            let headerRect = NSRect(
                x: self.leftMargin + horizontalOffset,
                y: self.topMargin,
                width: self.widthQuotient * column.width,
                height: self.rowHeight)
            
            horizontalOffset += widthQuotient * column.width
            
            let bezierPath = NSBezierPath(rect: headerRect)
            NSColor.red.setFill()
            bezierPath.fill()
            
            NSColor.blue.set()
            bezierPath.stroke()
            bezierPath.close()
            
            let columnTitle = column.title
            columnTitle.draw(in: headerRect.insetBy(dx: inset, dy: inset), withAttributes: attributes)
        }
        
        let firstEntryOfPage = self.currentPage * self.linesPerPage
        let lastEntryOfPage = ((currentPage + 1) * linesPerPage) > tableToPrint!.numberOfRows ? tableToPrint!.numberOfRows : ((currentPage + 1) * linesPerPage)
        self.numberOfRowsByPage = lastEntryOfPage - firstEntryOfPage
        
        for indexPage in 0 ..< ( lastEntryOfPage - firstEntryOfPage) {
            
            let row = firstEntryOfPage + indexPage
            var horizontalOffset: CGFloat = 0
            var numCol = 0
            var ofx: CGFloat = 16
            
            for column in tableToPrint!.tableColumns {
                
                if column.isHidden == true {
                    numCol += 1
                    continue
                }
                
                var valueAsStr = ""
                let columnWidth = column.width
                
                    // Header ???
                if let tableCellView = tableToPrint?.view(atColumn: numCol, row: row, makeIfNecessary: true) as? KSHeaderCellView {
                    
                        // draw triangle
                    let rectDis = NSRect( x: leftMargin + horizontalOffset, y: topMargin + rowHeight * CGFloat(indexPage + 1) + 4, width: 8 , height: 8)
                    
                    let center = CGPoint(x: rectDis.midX, y: rectDis.midY)
                    let side = rectDis.width
                    let bezierPathDis = trianglePathWithCenter(center: center, side: side)
                    
                    bezierPathDis.stroke()
                    bezierPathDis.fill()
                    bezierPathDis.close()
                    
                        // Now we can finally draw the entry
                    valueAsStr = (tableCellView.textField?.stringValue)!
                    attributes[.foregroundColor] = (tableCellView.textField?.textColor)!
                    
                    let fillColor = tableCellView.fillColor
                    
                    let rect = NSRect(
                        x: self.leftMargin + horizontalOffset + 10 ,
                        y: self.topMargin + self.rowHeight * CGFloat(indexPage + 1),
                        width: (self.pageRect.size.width - self.margin - 10 ) ,
                        height: self.rowHeight)
                    
                    horizontalOffset += self.widthQuotient * columnWidth
                    
                    let bezierPath = NSBezierPath(rect: rect)
                    fillColor.set()
                    bezierPath.fill()
                    
                    NSColor.lightGray.set()
                    bezierPath.stroke()
                    bezierPath.close()
                    
                    let stringRect = rect.insetBy(dx: inset, dy: inset)
                    valueAsStr.draw(in: stringRect, withAttributes: attributes)
                } else
                
                if let tableCellView = tableToPrint?.view(atColumn: numCol, row: row, makeIfNecessary: true) as? NSTableCellView {
                    let textField = (tableCellView.textField!)
                    
                    valueAsStr = textField.stringValue
                    attributes[.foregroundColor] = (tableCellView.textField?.textColor)!
                    
                    let rect = NSRect(
                        x: self.leftMargin + horizontalOffset + ofx,
                        y: self.topMargin + self.rowHeight * CGFloat(indexPage + 1),
                        width: self.widthQuotient * column.width - 2,
                        height: self.rowHeight)
                    
                    horizontalOffset += self.widthQuotient * columnWidth
                    
                    let stringRect = rect.insetBy(dx: inset, dy: inset)
                    valueAsStr.draw(in: stringRect, withAttributes: attributes)
                    
                    if ofx == 16 {
                        ofx = 2
                    }
                    
                }
                numCol += 1
            }
            self.drawVerticalGrids()
            self.drawHorizontalGrids()
        }
    }
    
    func trianglePathWithCenter(center: CGPoint, side: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        
        let startX = center.x - side / 2
        let startY = center.y - side / 2
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.line(to: CGPoint(x: startX + side, y: startY ))
        path.line(to: CGPoint(x: startX + side / 2, y: startY + side))
        path.close()
        
        return path
    }
    
    func drawVerticalGrids() {
        
        let columns = tableToPrint!.tableColumns
        var offsetX: CGFloat = 0.0
        
        var fromPoint = CGPoint(x: self.leftMargin, y: self.topMargin + self.rowHeight )
        var toPoint   = CGPoint(x: self.leftMargin, y: self.topMargin + self.rowHeight * CGFloat(self.numberOfRowsByPage + 1 ))
        drawLine(fromPoint, toPoint: toPoint)
        
        for i in 0 ..< columns.count {
            
            offsetX += self.widthQuotient * columns[i].width
            
                //draw the vertical lines
            fromPoint = CGPoint( x: self.leftMargin + offsetX , y: topMargin + rowHeight )
            toPoint = CGPoint( x: leftMargin + offsetX , y: topMargin + rowHeight * CGFloat(numberOfRowsByPage + 1 ) )
            
            drawLine(fromPoint, toPoint: toPoint)
        }
    }
    
    func drawHorizontalGrids() {
        
        for i in 0 ... numberOfRowsByPage {
            let fromPoint = NSPoint(
                x: leftMargin ,
                y: topMargin + rowHeight + (CGFloat(i) * rowHeight)
            )
            let toPoint = NSPoint(
                x: leftMargin + pageRect.size.width - rightMargin,
                y: topMargin + rowHeight + (CGFloat(i) * rowHeight)
            )
            drawLine(fromPoint, toPoint: toPoint)
        }
    }
    
    func drawLine( _ fromPoint: CGPoint,  toPoint: CGPoint) {
        let path = NSBezierPath()
        NSColor.lightGray.set()
        path.move(to: fromPoint)
        path.line(to: toPoint)
        path.lineWidth = 0.5
        path.stroke()
    }
    
}



