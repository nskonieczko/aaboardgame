public enum AATurnSequence: String, TurnSequence, Codable {
    case researchAndDevelopment = "R&D"
    case diplomaticActions = "Diplomatic"
    case purchasingUnits = "Purchasing"
    case combatActions = "Combat"
    case nonCombatActions = "Non-Combat"
    case mobilizeNewUnits = "Mobiling Units"
    case collectIncome = "Collect Income"
    case endOfTurn = "End of Turn"
    
    var title: String {
        rawValue
    }
    
    public func isEqual(to other: any TurnSequence) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        
        return self == other
    }
}

/*
 researchAndDevelopment
 
 - each nation can invest in a technology that is secret from the other side
 - once they get it, specfic units ill behave differently -
 - if US has super carrieer, their carrier can hold 3 vs 2 unit and take 3 hits before.
 
 */
