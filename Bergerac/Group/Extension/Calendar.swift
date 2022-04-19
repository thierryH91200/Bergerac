import Foundation

extension Calendar {

    func year(_ date: Date) -> Int {
        guard let year = dateComponents([.year], from: date).year else { fatalError() }
        return year
    }

    public func month(_ date: Date) -> Int {
        guard let month = dateComponents([.month], from: date).month else { fatalError() }
        return month
    }

    public func day(_ date: Date) -> Int {
        guard let day = dateComponents([.day], from: date).day else { fatalError() }
        return day
    }

    public func endOfDay( date: Date) -> Date {
        let from = self.date(byAdding: .day, value: 1, to: date)!
        var comps = dateComponents([.year, .month, .day], from: from)
        comps.second = -1
        return self.date(from: comps)!
    }

//    public func startOfMonthForDate(_ date: Date) -> Date {
//        var comp = self.dateComponents([.year, .month, .day], from: date)
//        comp.day = 1
//        return self.date(from: comp)!
//    }

//    public func endOfMonthForDate(_ date: Date) -> Date {
//        var comp = self.dateComponents([.year, .month, .day], from: date)
//        if let month = comp.month {
//            comp.month = month + 1
//        }
//        comp.day = 0
//        return self.date(from: comp)!
//    }

//    public func nextStartOfMonthForDate(_ date: Date) -> Date {
//        let firstDay = startOfMonthForDate(date)
//        var comp = DateComponents()
//        comp.month = 1
//        return self.date(byAdding: comp, to: firstDay)!
//    }

//    public func prevStartOfMonthForDate(_ date: Date) -> Date {
//        let firstDay = startOfMonthForDate(date)
//        var comp = DateComponents()
//        comp.month = -1
//        return self.date(byAdding: comp, to: firstDay)!
//    }
    
//    public func numberOfDaysInMonthForDate(_ date: Date) -> Int {
//        return range(of: .day, in: .month, for: date)?.count ?? 0
//    }

//    public func numberOfWeeksInMonthForDate(_ date: Date) -> Int {
//        return range(of: .weekOfMonth, in: .month, for: date)?.count ?? 0
//    }

}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
//    var isLastDayOfMonth: Bool {
//        return tomorrow.month != month
//    }
    
    // normalise to midnight UTC
//    func dpt_normalise() -> Date {
//        
//        let calendar = Calendar.current
//        var components: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
//        
//        components.hour = 0
//        components.minute = 0
//        components.second = 0
//        components.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
//        return calendar.date(from: components)!
//    }
    
}

//extension Date {
//    /// Returns the amount of years from another date
//    func years(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
//    }
//    /// Returns the amount of months from another date
//    func months(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
//    }
//    /// Returns the amount of weeks from another date
//    func weeks(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
//    }
//    /// Returns the amount of days from another date
//    func days(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
//    }
//    /// Returns the amount of hours from another date
//    func hours(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
//    }
//    /// Returns the amount of minutes from another date
//    func minutes(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
//    }
//    /// Returns the amount of seconds from another date
//    func seconds(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
//    }
//    /// Returns the amount of nanoseconds from another date
//    func nanoseconds(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
//    }
//    /// Returns the a custom time interval description from another date
//    func offset(from date: Date) -> String {
//        if years(from: date)   > 0 { return "\(years(from: date))y"   }
//        if months(from: date)  > 0 { return "\(months(from: date))M"  }
//        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
//        if days(from: date)    > 0 { return "\(days(from: date))d"    }
//        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
//        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
//        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
//        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
//        return ""
//    }
//}
//
//
//

