enum TrackerCategories {
    static let important = "Важное"
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}
