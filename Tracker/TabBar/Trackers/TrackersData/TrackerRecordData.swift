import Foundation

struct TrackerRecord: Hashable {
    let id: UInt
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id && lhs.date == rhs.date
    }
}
