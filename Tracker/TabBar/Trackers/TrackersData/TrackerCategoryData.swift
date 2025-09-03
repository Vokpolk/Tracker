enum TrackerCategories {
    static let important = "ОченьВажное"
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}
