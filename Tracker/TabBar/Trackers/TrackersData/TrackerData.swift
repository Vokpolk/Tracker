import UIKit

enum WeekDay: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

struct Tracker {
    let id: UInt
    let name: String
    let color: UIColor
    let emoji: String
    //let shedule: Shedule
    let weekDays: [WeekDay]
}
