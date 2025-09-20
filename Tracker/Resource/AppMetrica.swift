import AppMetricaCore

final class AppMetricaManager {
    static let shared = AppMetricaManager()
    
    private init() {}
    
    func reportScreenOpen(screen: String) {
        let parameters: [String: Any] = [
            "event": "open",
            "screen": screen
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportScreenClose(screen: String) {
        
        let parameters: [String: Any] = [
            "event": "close",
            "screen": screen
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportAddTrack(screen: String) {
        
        let parameters: [String: Any] = [
            "event": "click",
            "screen": screen,
            "item": "add_track"
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportTrack(screen: String) {
        
        let parameters: [String: Any] = [
            "event": "click",
            "screen": screen,
            "item": "track"
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportFilter(screen: String) {
        
        let parameters: [String: Any] = [
            "event": "click",
            "screen": screen,
            "item": "filter"
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportEdit(screen: String) {
        
        let parameters: [String: Any] = [
            "event": "click",
            "screen": screen,
            "item": "edit"
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    func reportDelete(screen: String) {
        
        let parameters: [String: Any] = [
            "event": "click",
            "screen": screen,
            "item": "delete"
        ]
        
        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
}
