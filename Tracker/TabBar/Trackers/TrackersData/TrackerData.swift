import UIKit

enum WeekDay: Int, Codable {
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
    let weekDays: [WeekDay]
    
    init(
        id: UInt,
        name: String,
        color: NSObject?,
        emoji: String,
        weekDays: [WeekDay]
    ) {
        self.id = id
        self.name = name
        self.color = (color as? UIColor) ?? UIColor.clear
        self.emoji = emoji
        self.weekDays = weekDays
    }
}
