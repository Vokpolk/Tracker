import AppMetricaCore

enum AppMetricaEvent {
    enum Event: String {
        case open, close, click
    }
    
    enum Screen: String {
        case main = "Main"
        case onboarding = "Onboarding"
        case statistics = "Statisctics"
        case filter = "Filter"
        //etc
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
        case none = ""
    }
    
    struct Payload {
        let event: Event
        let screen: Screen
        let item: Item?
        
        var parameters: [String: String] {
            var dict: [String: String] = [
                "event": event.rawValue,
                "screen": screen.rawValue
            ]
            if let item, item != .none {
                dict["item"] = item.rawValue
            }
            return dict
        }
    }
}

final class AppMetricaManager {
    static let shared = AppMetricaManager()
    private init() {}
    
    func report(_ payload: AppMetricaEvent.Payload) {
        AppMetrica.reportEvent(
            name: "event",
            parameters: payload.parameters) { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            }
    }
}
