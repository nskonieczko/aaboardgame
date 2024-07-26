public enum AAGameOrder: String, GameOrder {
    case germany
    case japan
    case unitedStates
    case unitedKingdom
    case china
    case italy
    case commonwealth
    case france
    case russia
    
    public func next(after order: Order) -> Order {
        let allCases = Self.allCases
        guard let currentIndex = allCases.firstIndex(of: self), currentIndex + 1 < allCases.count else {
            return allCases.first!
        }
        return allCases[currentIndex + 1]
    }
}

public enum Country: String, CaseIterable, Codable {
    case germany
    case japan
    case unitedStates
    case unitedKingdom
    case china
    case italy
    case commonwealth
    case france
    case russia
    
    static var axis: Set<Country> {
        [.germany, .japan, .italy]
    }
    
    static var allies: Set<Country> {
        Set(Self.allCases).subtracting(axis)
    }
}
