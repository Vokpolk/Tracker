enum TrackerCategories {
    static let important = "Важное"
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}
