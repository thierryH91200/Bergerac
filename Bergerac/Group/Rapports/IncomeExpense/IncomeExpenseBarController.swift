import AppKit
import Charts
import SwiftDate

final class IncomeExpenseBarController: CommonGraph {
    
    public var delegate: FilterDelegate?
    
    @IBOutlet var chartView: BarChartView!
    @IBOutlet weak var splitView: NSSplitView!
    
    let hourSeconds = 3600.0 * 24.0 // one day
    let context = mainObjectContext

    var startDate = Date()
    var endDate   = Date()

    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    var resultArrayExpense = [DataGraph]()
    var resultArrayIncome  = [DataGraph]()
    var label  = [String]()

    let formatterDate: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM yy", options: 0, locale: Locale.current)
        return fmt
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.receive( self, selector: #selector(updateChangeCompte(_:)), name: .updateAccount)

        if sliderViewController == nil {
            sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            sliderViewController?.delegate = self
        }
        
        splitView.addSubview((sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        initChart()
        updateAccount ()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Income Expense Chart"
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        })
    }
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .updateAccount)
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        
        updateAccount ()
        setDataHorizontal()
    }
    
    private func initChart() {
        
        // MARK: General
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled      = false
        chartView.drawValueAboveBarEnabled  = true
        chartView.maxVisibleCount           = 60
        chartView.drawBordersEnabled        = true
        chartView.drawGridBackgroundEnabled = true
        chartView.gridBackgroundColor       = .windowBackgroundColor
        chartView.fitBars                   = true

        chartView.pinchZoomEnabled          = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.dragEnabled               = false
        chartView.noDataText = Localizations.Chart.No_chart_Data_Available

        // MARK: xAxis
        let xAxis            = chartView.xAxis
        xAxis.centerAxisLabelsEnabled = true
        xAxis.drawGridLinesEnabled    = true
        xAxis.granularity = 1.0
        xAxis.gridLineWidth = 2.0
        xAxis.labelCount = 20
        xAxis.labelFont      = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .labelColor

        // MARK: leftAxis
        let leftAxis                   = chartView.leftAxis
        leftAxis.labelFont             = NSFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.labelCount            = 6
        leftAxis.drawGridLinesEnabled  = true
        leftAxis.granularityEnabled    = true
        leftAxis.granularity           = 1
        leftAxis.valueFormatter        = CurrencyValueFormatter()
        leftAxis.labelTextColor        = .labelColor

        // MARK: rightAxis
        chartView.rightAxis.enabled    = false
        
        // MARK: legend
        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside                    = true
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        legend.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!
        legend.textColor = .labelColor

        // MARK: description
        chartView.chartDescription?.enabled  = false
    }
    
    /// Recover data between 2 dates.
    /// The dates come from the slider
    /// https://stackoverflow.com/questions/40657193/swift-3-sum-value-with-group-by-of-an-array-of-objects
    private func updateChartData()
    {
        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!

        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p3 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2, p3])

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listTransactions = try context!.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        
        // grouped and sum
        self.resultArrayExpense.removeAll()
        self.resultArrayIncome.removeAll()
        var dataArray = [DataGraph]()
        
        for listTransaction in listTransactions {
            
            let value = listTransaction.amount
            let id   = listTransaction.sectionIdentifier!
            
            let data  = DataGraph(name: id, value: value)
            dataArray.append(data)
        }
        
        let allKeys = Set<String>(dataArray.map { $0.name })
        for key in allKeys {
            var data = dataArray.filter({ $0.name == key && $0.value < 0 })
            var sum = data.map({ $0.value }).reduce(0, +)
            self.resultArrayExpense.append(DataGraph(name: key, value: sum))
            
            data = dataArray.filter({ $0.name == key && $0.value >= 0 })
            sum = data.map({ $0.value }).reduce(0, +)
            self.resultArrayIncome.append(DataGraph(name: key, value: sum))
        }
        
        self.resultArrayExpense = resultArrayExpense.sorted(by: { $0.name < $1.name })
        self.resultArrayIncome = resultArrayIncome.sorted(by: { $0.name < $1.name })
    }
    
    private func setDataCount()
    {
        guard resultArrayExpense.isEmpty == false && resultArrayIncome.isEmpty == false else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        let groupSpace = 0.2
        let barSpace = 0.00
        let barWidth = 0.4
        
        // MARK: BarChartDataEntry
        var entriesExpense = [BarChartDataEntry]()
        var entriesIncome = [BarChartDataEntry]()
        
        self.label.removeAll()
        
        var components = DateComponents()
        var dateString = ""
        
        for i in 0 ..< resultArrayExpense.count {
            entriesExpense.append(BarChartDataEntry(x: Double(i), y: abs(resultArrayExpense[i].value)))
            entriesIncome.append(BarChartDataEntry(x: Double(i), y: resultArrayIncome[i].value))
            
            let numericSection = Int(resultArrayExpense[i].name)
            components.year = numericSection! / 100
            components.month = numericSection! % 100
            
            if let date = Calendar.current.date(from: components) {
                dateString = formatterDate.string(from: date)
            }
            label.append(dateString)
        }
        
        // MARK: BarChartDataSet
        var dataSet1 = BarChartDataSet()
        var dataSet2 = BarChartDataSet()
        
        if chartView.data == nil {
            
            var label = Localizations.Graph.Expense
            dataSet1 = BarChartDataSet(entries: entriesExpense, label: label)
            dataSet1.colors = [#colorLiteral(red: 1, green: 0.1474981606, blue: 0, alpha: 1)]
            dataSet1.valueFormatter = DefaultValueFormatter(formatter: formatterPrice)
            
            label = Localizations.Graph.Income
            dataSet2 = BarChartDataSet(entries: entriesIncome, label: label)
            dataSet2.colors = [#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
            dataSet2.valueFormatter = DefaultValueFormatter(formatter: formatterPrice)
        } else {
            
            dataSet1 = (chartView.data!.dataSets[0] as! BarChartDataSet )
            dataSet1.replaceEntries( entriesExpense )
            
            dataSet2 = (chartView.data!.dataSets[1] as! BarChartDataSet )
            dataSet2.replaceEntries( entriesIncome )
        }
        
        // MARK: BarChartData
        let data = BarChartData(dataSets: [dataSet1, dataSet2])
        
        data.barWidth = barWidth
        data.groupBars( fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(8.0))!)
        data.setValueTextColor(.black)
        
        let groupCount = resultArrayExpense.count + 1
        let startYear = 0
        let endYear = startYear + groupCount
        
        self.chartView.xAxis.axisMinimum = Double(startYear)
        self.chartView.xAxis.axisMaximum = Double(endYear)
        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: label)

        self.chartView.data = data
        
        self.chartView.data?.notifyDataChanged()
        self.chartView.notifyDataSetChanged()
    }
}

extension IncomeExpenseBarController: SliderHorizontalDelegate {
    func setDataHorizontal() {
        updateChartData()
        setDataCount()
    }
}

extension IncomeExpenseBarController: ChartViewDelegate
{
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        var index = highlight.x
        let entryX = entry.x
        let dataSetIndex = Int(highlight.dataSetIndex)
        
        let firstDate = sliderViewController?.firstDate
        
        index = 0
        var date2 = Date(timeIntervalSince1970: ((index * self.hourSeconds) + firstDate!))
        let idx = Int(entryX)
        date2 = date2 + idx.months
        let startDate = date2.startOfMonth()
        let endDate = date2.endOfMonth()

        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = dataSetIndex == 0 ? NSPredicate(format: "amount < 0" ) : NSPredicate(format: "amount >= 0" )
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2, p3, p4])

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
        
        delegate?.applyFilter( fetchRequest)
    }
    
    public func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
    }
    
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: self.startOfMonth())!
    }
}


