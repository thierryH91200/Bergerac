//
//  CommonGraph.swift
//  Bergerac
//
//  Created by thierry hentic on 07/03/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import Cocoa
import Charts

class CommonGraph: NSViewController {
    
    var listTransactions = [EntityTransactions]()
    var firstDate: TimeInterval = 0.0
    var lastDate: TimeInterval = 0.0
    
    var sliderViewController: SliderViewHorizontalController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func initializeLegend(_ legend: Legend) {
        legend.horizontalAlignment           = .left
        legend.verticalAlignment             = .top
        legend.orientation                   = .vertical
        legend.drawInside                    = true
        legend.form                          = .square
        legend.formSize                      = 9.0
        legend.font                          = NSFont.systemFont(ofSize: CGFloat(11.0))
        legend.xEntrySpace                   = 4.0
    }

    func updateAccount () {
        listTransactions = ListTransactions.shared.entities
        if listTransactions.isEmpty == true || ListTransactions.shared.ascending == false {
            listTransactions = ListTransactions.shared.getAllDatas()
        }
        if listTransactions.isEmpty == false {
            
            firstDate = (listTransactions.first?.dateOperation?.timeIntervalSince1970)!
            lastDate = (listTransactions.last?.dateOperation?.timeIntervalSince1970)!
            
            sliderViewController?.initData(firstDate: firstDate, lastDate: lastDate)
            sliderViewController?.mySlider.isEnabled = true
            
        } else {
            sliderViewController?.mySlider.isEnabled = false
        }
    }
}
