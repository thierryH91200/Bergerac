import AppKit
import SwiftDate

extension ListTransactionsController: NSDatePickerCellDelegate {
    
    func datePickerCell(_ datePickerCell: NSDatePickerCell,
                        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
                        timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?) {
        
        guard datePicker.isEnabled == true else { return }
        guard currentAccount != nil else { return }
        
        var proposedDate = proposedDateValue.pointee as Date
        proposedDate = proposedDate.noon
        
        let datePickerValue = datePicker.dateValue.noon
        guard proposedDate == datePickerValue else { return }
                
        let entitySchedules = Scheduler.shared.getAllDatas()
        
        for entitySchedule in entitySchedules {
            var dateValeur =  entitySchedule.dateValeur!
            let frequence = Int(entitySchedule.frequence)
            
            while datePickerValue.timeIntervalSinceReferenceDate > dateValeur.timeIntervalSinceReferenceDate {

                Scheduler.shared.createTransaction(entitySchedule: entitySchedule, dateValeur: dateValeur)
                
                let amount = formatterPrice.string(from: NSDecimalNumber(value:entitySchedule.amount))
                let  dateString = formatterDate.string(from: dateValeur)
                let subtitle = entitySchedule.libelle! + " " + dateString + " " + amount!
                notificationCenter.shared.generateNotification(title: "Bergerac Echeancier", body: "Ajout d'une transaction", subtitle: subtitle, sound: true)

                let type = entitySchedule.typeFrequence
                switch type
                {
                case 0:
                    dateValeur = dateValeur + frequence.days
                
                case 1:
                    dateValeur = dateValeur + frequence.weeks
                
                case 2:
                    dateValeur = dateValeur + frequence.months
                
                case 3:
                    dateValeur = dateValeur + frequence.years
                
                default:
                    print("what ????")
                }
                entitySchedule.nextOccurence += 1
            }
            entitySchedule.dateValeur = dateValeur
        }
        currentAccount?.dateEcheancier = datePickerValue
        getAllData()
        reloadData(false)
    }
    
    func updateScheduler() {
        
        let datePickerValue = datePicker.dateValue.noon
//        guard proposedDate == datePickerValue else { return }
                
        let entitySchedules = Scheduler.shared.getAllDatas()
        
        for entitySchedule in entitySchedules {
            var dateValeur =  entitySchedule.dateValeur!
            let frequence = Int(entitySchedule.frequence)
            
            while dateValeur < datePickerValue {
                let type = entitySchedule.typeFrequence
                switch type
                {
                case 0:
                    dateValeur = dateValeur + frequence.days
                
                case 1:
                    dateValeur = dateValeur + frequence.weeks
                
                case 2:
                    dateValeur = dateValeur + frequence.months
                
                case 3:
                    dateValeur = dateValeur + frequence.years
                
                default:
                    print("what ????")
                }
                entitySchedule.nextOccurence += 1
                Scheduler.shared.createTransaction(entitySchedule: entitySchedule, dateValeur: dateValeur)
            }
            entitySchedule.dateValeur = dateValeur
        }
        
        currentAccount?.dateEcheancier = datePickerValue
        self.getAllData()
        self.reloadData(true)
    }
    
}
