public enum AATurnSequence: String, TurnSequence {
    case diplomaticActions
    case purchasingUnits
    case combatActions
    case nonCombatActions
    case endOfTurn
    
    public func canPerform(action: any TurnAction) -> Bool {
        switch self {
        case .diplomaticActions:
            return action is DiplomaticAction
        case .purchasingUnits:
            return action is PurchasingUnitAction
        case .combatActions:
            return action is CombatAction
        case .nonCombatActions:
            return action is NonCombatAction
        case .endOfTurn:
            return false
        }
    }
    
    public func isEqual(to other: any TurnSequence) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        
        return self == other
    }
}
