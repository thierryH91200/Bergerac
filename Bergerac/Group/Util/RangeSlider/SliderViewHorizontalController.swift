import AppKit

@objc public protocol SliderHorizontalDelegate
{
    func setDataHorizontal()
}

final class SliderViewHorizontalController: NSViewController {
    
    public weak var delegate: SliderHorizontalDelegate?
    
    @IBOutlet weak var mySlider: RangeSliderHorizontal!
    
    @IBOutlet weak var slider1Label1: NSTextField!
    @IBOutlet weak var slider1Label2: NSTextField!
    @IBOutlet weak var slider1Label3: NSTextField!
    
    @IBOutlet weak var stepper1: NSStepper!
    @IBOutlet weak var stepper2: NSStepper!
    
    private let oneDay = 3600.0 * 24.0 // one day
    
    private var startDate = Date()
    private var endDate = Date()
    
    var firstDate: TimeInterval = 0.0
    var lastDate: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.initSlider()
    }
    
    private func initSlider() {
        
        mySlider.onControlChanged = {
            (slider: RangeSlider) -> Void in
            
            self.delegate?.setDataHorizontal()
            
            self.stepper1.doubleValue = self.mySlider.start
            self.stepper2.doubleValue = self.mySlider.end
            
            self.formatSlider()
        }
    }
    
    func initData(firstDate: TimeInterval, lastDate: TimeInterval)  {
        
        self.firstDate = firstDate
        self.lastDate = lastDate
        
        let maxValue = (self.lastDate - self.firstDate) / oneDay
        
        self.mySlider.minValue = 0
        self.mySlider.maxValue = maxValue
        
        self.stepper1.minValue = 0
        self.stepper1.maxValue = maxValue
        self.stepper1.doubleValue = 0
        
        self.stepper2.minValue = 0
        self.stepper2.maxValue = maxValue
        self.stepper2.doubleValue = maxValue
        
        self.mySlider.snapsToIntegers = true
        self.mySlider.isEnabled = true
        
        self.slider1Label3.bind(NSBindingName( "intValue"), to: mySlider!, withKeyPath: "length", options: nil)
        self.formatSlider()
    }
    
    private func formatSlider() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        var date2 = Date(timeIntervalSince1970: ((mySlider.start * self.oneDay) + self.firstDate)  )
        var date = dateFormatter.string(from: date2)
        self.slider1Label1.stringValue = date
        
        date2 = Date(timeIntervalSince1970: ((mySlider.end * self.oneDay) + self.firstDate)  )
        date = dateFormatter.string(from: date2)
        self.slider1Label2.stringValue = date
    }
    
    func calcStartEndDate() -> (Date, Date) {
        
        let calendar = Calendar.current
        
        var date2 = Date(timeIntervalSince1970: ((mySlider.start * self.oneDay) + self.firstDate))
        self.startDate = calendar.startOfDay(for: date2)
        
        date2 = Date(timeIntervalSince1970: ((mySlider.end * self.oneDay) + self.firstDate))
        self.endDate = calendar.endOfDay(date: date2 )
        return (startDate, endDate)
    }

    
    
    @IBAction func changeStepperStart(_ sender: NSStepper) {
        
        self.mySlider.start = sender.doubleValue
    }
    
    @IBAction func changeStepperEnd(_ sender: NSStepper) {
        
        self.mySlider.end = sender.doubleValue
    }
    
}
