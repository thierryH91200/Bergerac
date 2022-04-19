//
//  ChartView.swift
//  Bergerac
//
//  Created by thierry hentic on 07/03/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import AppKit
import Charts

extension BarChartView {
    
    func setUpLegend() -> Legend {
        let legend = self.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside  = true
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        legend.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!
        return legend
    }

}
