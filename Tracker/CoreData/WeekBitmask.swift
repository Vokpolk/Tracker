final class WeekBitmask {
    
    static func daysToMask(_ flags: [WeekDay]) -> Int16 {
        var result: Int16 = 0
        if flags.contains(.monday) {
            result += 0b1
        }
        if flags.contains(.tuesday) {
            result += 0b10
        }
        if flags.contains(.wednesday) {
            result += 0b100
        }
        if flags.contains(.thursday) {
            result += 0b1000
        }
        if flags.contains(.friday) {
            result += 0b10000
        }
        if flags.contains(.saturday) {
            result += 0b100000
        }
        if flags.contains(.sunday) {
            result += 0b1000000
        }
        return result
    }

    static func maskToDays(_ mask: Int16) -> [WeekDay] {
        var result: [WeekDay] = []
        
        if mask & 0b1 != 0 {
            result.append(.monday)
        }
        if mask & 0b10 != 0 {
            result.append(.tuesday)
        }
        if mask & 0b100 != 0 {
            result.append(.wednesday)
        }
        if mask & 0b1000 != 0 {
            result.append(.thursday)
        }
        if mask & 0b10000 != 0 {
            result.append(.friday)
        }
        if mask & 0b100000 != 0 {
            result.append(.saturday)
        }
        if mask & 0b1000000 != 0 {
            result.append(.sunday)
        }
        
        return result
    }
}

