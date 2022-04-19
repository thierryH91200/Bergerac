import AppKit
import Charts


final class CategoryBarController: CommonGraph
{
    public var delegate: FilterDelegate?
    
    @IBOutlet var chartView: BarChartView!
    @IBOutlet weak var backToBrands: NSButton!
    @IBOutlet weak var splitView: NSSplitView!
       
    var label  = [String]()
    var data = [DataGraph]()
    var resultArray = [DataGraph]()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    var startDate = Date()
    var endDate = Date()
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove( self, name: .updateAccount)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Bar Chart"
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        })
        delegate?.updateListeTransactions( [])
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.receive( self, selector: #selector(updateChangeAccount), name: .updateAccount)
        
        backToBrands.isEnabled = false
        
        if sliderViewController == nil {
            sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            sliderViewController?.delegate = self
        }
        splitView.addSubview((sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        initChart()

        updateAccount ()
        updateChartData()
        setDataHorizontal()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        
        updateAccount ()
        updateChartData()
        setDataHorizontal()
    }
    
    private func initChart() {
        // MARK: General
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled      = false
        chartView.drawValueAboveBarEnabled  = true
        chartView.maxVisibleCount           = 60
        chartView.drawGridBackgroundEnabled = true
        chartView.drawBordersEnabled        = true
        chartView.gridBackgroundColor       = .windowBackgroundColor
        chartView.fitBars                   = true

        chartView.pinchZoomEnabled          = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.dragEnabled               = false
        chartView.noDataText = Localizations.Chart.No_chart_Data_Available
        
        // MARK: Axis
        setUpAxis()
        
        // MARK: Legend
        initializeLegend(chartView.legend)
        chartView.legend.enabled = false
        
        // MARK: Description
        let bounds                           = chartView.bounds
        let point    = CGPoint( x: bounds.width / 2, y: bounds.height * 0.25)
        chartView.chartDescription?.enabled  = true
        chartView.chartDescription?.text     = Localizations.Graph.Rubrique
        chartView.chartDescription?.position = point
        chartView.chartDescription?.font     = NSFont(name: "HelveticaNeue-Light", size: CGFloat(24.0))!
    }
    
    func setUpAxis() {
        // MARK: xAxis
        let xAxis                      = chartView.xAxis
        xAxis.labelPosition            = .bottom
        xAxis.labelFont                = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        xAxis.drawGridLinesEnabled     = true
        xAxis.granularity              = 1
        xAxis.enabled                  = true
        xAxis.labelTextColor           = .labelColor
        xAxis.labelCount               = 10

        // MARK: leftAxis
        let leftAxis                   = chartView.leftAxis
        leftAxis.labelFont             = NSFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.labelCount            = 12
        leftAxis.drawGridLinesEnabled  = true
        leftAxis.granularityEnabled    = true
        leftAxis.granularity           = 1
        leftAxis.valueFormatter        = CurrencyValueFormatter()
        leftAxis.labelTextColor        = .labelColor

        // MARK: rightAxis
        chartView.rightAxis.enabled    = false

    }
    
    override func initializeLegend(_ legend: Legend) {
        legend.horizontalAlignment = .right
        legend.verticalAlignment   = .top
        legend.orientation         = .vertical
        legend.drawInside          = true
//        legend.form              = .square
//        legend.formSize          = 9.0
        legend.yOffset             = 10.0
        legend.xOffset             = 10.0
        legend.yEntrySpace         = 0.0
        legend.textColor           = NSColor.labelColor
        legend.font                = NSFont.systemFont(ofSize : CGFloat(11.0))
    }

    /// Récupére les données entre 2 dates.
    /// Les dates proviennent du slider
    /// https://stackoverflow.com/questions/40657193/swift-3-sum-value-with-group-by-of-an-array-of-objects
    private func updateChartData()
    {
        let context = mainObjectContext

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
        var dataArray = [DataGraph]()
        
        var name = ""
        var value = 0.0
        var color = NSColor.blue
        
        for listTransaction in listTransactions {
            let sousOperations = listTransaction.sousOperations?.allObjects  as! [EntitySousOperations]
            for sousOperation in sousOperations {
                name  = (sousOperation.category?.rubric!.name)!
                value = sousOperation.amount
                color = sousOperation.category?.rubric?.color as! NSColor
            }
            dataArray.append( DataGraph(name: name, value: value, color: color))
        }
        
        resultArray.removeAll()
        let allKeys = Set<String>(dataArray.map { $0.name })
        for key in allKeys {
            let data = dataArray.filter({ $0.name == key })
            let sum = data.map({ $0.value }).reduce(0, +)
            resultArray.append(DataGraph(name: key, value: sum, color: data[0].color))
        }
        resultArray = resultArray.sorted(by: { $0.name < $1.name })
    }
    
    private func updateChartDataCat(_ nameRubric: String )
    {
        let context = mainObjectContext

        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!
        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name == %@).@count > 0", nameRubric)
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2, p3, p4])
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listTransactions = try context!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        // grouped and sum
        resultArray.removeAll()
        var dataArray = [DataGraph]()
        for listTransaction in listTransactions {
            
            let sousOperations = listTransaction.sousOperations?.allObjects  as! [EntitySousOperations]
            
            for sousOperation in sousOperations {
                
                let amount = sousOperation.amount
                let nameCategory   = sousOperation.category?.name
                let color = sousOperation.category?.rubric?.color as! NSColor
                let data  = DataGraph(name: nameCategory!, value: amount, color: color)
                dataArray.append(data)
            }
        }
        
        let allKeyNames = Set<String>(dataArray.map { $0.name })
        for keyName in allKeyNames {
            let data = dataArray.filter({ $0.name == keyName })
            let sum = data.map({ $0.value }).reduce(0, +)
            resultArray.append(DataGraph(name: keyName, value: sum, color: data[0].color))
        }
        resultArray = resultArray.sorted(by: { $0.name < $1.name })
    }
    
    @IBAction func actionBack(_ sender: Any) {
        
        self.backToBrands.isEnabled = false
        self.chartView.chartDescription?.text = Localizations.Graph.Rubrique
        self.setDataHorizontal()
        self.delegate?.updateListeTransactions( [])
    }
    
    private func setDataCount()
    {
        guard resultArray.isEmpty == false else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        // MARK: BarChartDataEntry
        var entries = [BarChartDataEntry]()
        var colors = [NSColor]()
        label.removeAll()
        colors.removeAll()
        
        for i in 0 ..< resultArray.count {
            entries.append(BarChartDataEntry(x: Double(i), y: resultArray[i].value))
            label.append(resultArray[i].name)
            colors.append(resultArray[i].color)
        }
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: label)

        if chartView.data == nil {
            // MARK: BarChartDataSet
            let label = Localizations.Graph.Rubrique
            var dataSet = BarChartDataSet()
            
//            let block: (Int) -> BarChartDataEntry = { (i) -> BarChartDataEntry in
//                return BarChartDataEntry(x: Double(i), y: Double(self.resultArray[i].value))
//            }
//
//            let yVals1 = (0 ..< 1).map(block)
//            let yVals2 = (0 ..< 1).map(block)
//            let yVals3 = (0 ..< 1).map(block)
//            let yVals4 = (0 ..< 1).map(block)


            
                //            for i in 0..<entries.count {
            dataSet = BarChartDataSet(entries: entries, label: label)
            
            dataSet.colors = colors
            dataSet.drawValuesEnabled = true
            dataSet.barBorderWidth = 0.1
            dataSet.valueFormatter = DefaultValueFormatter(formatter: formatterPrice)
                //            }
            
            chartView.xAxis.labelCount  = entries.count

            // MARK: BarChartData
            let data = BarChartData()
            data.addDataSet(dataSet)

            data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
            data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
            data.setValueTextColor(NSColor.black)
            chartView.data = data
        } else {
            // MARK: BarChartDataSet
            let set1 = chartView.data!.dataSets[0] as! BarChartDataSet
            set1.colors = colors
            set1.replaceEntries( entries )
            
            // MARK: BarChartData
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }
    }
}

extension CategoryBarController: SliderHorizontalDelegate {
    func setDataHorizontal() {
        updateChartData()
        setDataCount()
    }
}

extension CategoryBarController: ChartViewDelegate
{
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        let index = Int(highlight.x)
        
        let labelStr = Localizations.Graph.Rubrique
        if  chartView.chartDescription?.text == labelStr  {
            
            self.backToBrands.isEnabled = true
            chartView.chartDescription?.text = self.label[index]
            
            self.updateChartDataCat( self.label[index])
            self.setDataCount()
        } else {
            let rub = chartView.chartDescription?.text
            
            let p1 = NSPredicate(format: "account == %@", currentAccount!)
            let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.name == %@).@count > 0", self.label[index])
            let p5 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name == %@).@count > 0", rub!)
            let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
            let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
            let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2, p3, p4, p5])
            
            let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
            
            delegate?.applyFilter( fetchRequest)
        }
    }

    public func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
    }
    
}
