public enum AATurnSequence: String, TurnSequence {
    case researchAndDevelopment
    case diplomaticActions
    case purchasingUnits
    case combatActions
    case nonCombatActions
    case mobilizeNewUnits
    case collectIncome
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
        case .collectIncome:
            return action is CollectIncomeAction
        case .researchAndDevelopment:
            return action is ResearchAndDevelopmentAction
        case .mobilizeNewUnits:
            return action is MobilizeNewUnitsAction
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

/*
 researchAndDevelopment
 
 - each nation can invest in a technology that is secret from the other side
 - once they get it, specfic units ill behave differently -
 - if US has super carrieer, their carrier can hold 3 vs 2 unit and take 3 hits before.
 
 */
