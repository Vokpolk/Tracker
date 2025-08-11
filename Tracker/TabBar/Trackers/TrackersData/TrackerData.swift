import UIKit

enum WeekDay: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

struct Tracker {
    let id: UInt
    let name: String
    let color: UIColor
    let emoji: String
    //let shedule: Shedule
    let weekDays: [WeekDay]
}
