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

public enum Country: String, CaseIterable, Codable, Hashable {
    case germany
    case japan
    case unitedStates = "United States"
    case unitedKingdom
    case china
    case italy
    case commonwealth
    case france
    case russia
    
    /* Diplotmatic situation */
    
    //    static var startingAtWar: Set(Country, Country)
    // france, uk, commonwealth, China -> italy, germany
    // japan -> China
    
    /* Russia specific stuffs */
    // Russia has a very specific relationship with Japan.
    // if axis doesnt declare with Russia or US,
    // Russia, axis ignore them, comes into war on round 4
    // start of russia round 4 they auto get added. Germany and italy
    // no relationship with Japan, need specfic action for war with Japan. or verbal declartion by Russia ONLY.
    // They could come in round 3 (stricly round 3), with 10 or more axis units on 3 specific terrorites: poland, romiania, sloveaka/hungary.
    
    
    /*
     Japan specific stuffs
     
     - just at war with China ONLY
     - if by UK, 4th round, Japan has not delcared war against commonwelat, france, UK then all three are auto at war with Japan
     - russia and US cant declare war at some points
     - UK, Commonwealth, France can declare war on Japan at any turn
     
     */
    
    /*
     
     US specific stuffs
     
     - axis waits very long, US will auto come into war at the end of their round 3, after collect income phase
     - just have to be attacked by axis powers
     - US, cant declare war lets say round 2, or attack enemy units. They must attacked or end of round 3.
     
     */
    
    static var axis: Set<Country> {
        [.germany, .japan, .italy]
    }
    
    static var allies: Set<Country> {
        Set(Self.allCases).subtracting(axis)
    }
    
    var industrialOutput: Int {
        return 42
    }
}
