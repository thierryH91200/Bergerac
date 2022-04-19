//
//  SliderViewVerticalController.swift
//  RangeSliderDemo
//
//  Created by thierry hentic on 15/04/2019.
//  Copyright © 2019 thierry hentic. All rights reserved.
//

import AppKit

@objc public protocol SliderVerticalDelegate
{
    func setDataVertical()
}


class SliderViewVerticalController: NSViewController {

    @IBOutlet weak var slider1Label1: NSTextField!
    @IBOutlet weak var slider1Label2: NSTextField!
    @IBOutlet weak var mySlider: RangeSliderVertical!
    
    public weak var delegate: SliderVerticalDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.configureFormatters()
        initSlider()
        
        slider1Label1.bind(NSBindingName(rawValue: "doubleValue"), to: mySlider!, withKeyPath: "start", options: nil)
        slider1Label2.bind(NSBindingName(rawValue: "doubleValue"), to: mySlider!, withKeyPath: "end", options: nil)
        
        mySlider.start = -1_000.0
        mySlider.end = 1_000.0

    }
    
    func configureFormatters() {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        for textField in [slider1Label1, slider1Label2] {
            textField!.formatter = formatter
        }
    }
    
    private func initSlider() {
        
        mySlider.onControlChanged = {
            (slider: RangeSlider) -> Void in
            
            self.delegate?.setDataVertical()
        }
    }

}
