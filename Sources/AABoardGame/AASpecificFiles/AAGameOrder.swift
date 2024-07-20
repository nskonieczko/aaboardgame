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
    
    public func next(after order: any Order) -> any Order {
        return Self.russia
    }
}
