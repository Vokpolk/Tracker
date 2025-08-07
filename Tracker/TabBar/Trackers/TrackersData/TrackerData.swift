import UIKit

struct Shedule {
    var monday: Bool = false
    var tuesday: Bool = false
    var wednesday: Bool = false
    var thursday: Bool = false
    var friday: Bool = false
    var saturday: Bool = false
    var sunday: Bool = false
}

struct Tracker {
    let id: UInt
    let name: String
    let color: UIColor
    let emoji: String
    let shedule: Shedule
}
