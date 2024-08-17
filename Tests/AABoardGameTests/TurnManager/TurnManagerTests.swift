import XCTest

@testable import AABoardGame

class TurnManagerTests: XCTestCase {
    
    func testNonCombatAction() {
        let action = NonCombatAction()
        XCTAssertEqual(action.sequence, .nonCombatActions)
    }
    
    func testTurnManagerInitialization() {
        let initialPhase = AATurnSequence.nonCombatActions
        let turnManager = TurnManager(initialPhase: initialPhase)
        
        XCTAssertEqual(turnManager.currentSequence as? AATurnSequence, AATurnSequence.nonCombatActions)
    }
        
    func testPerformAction() {
        let initialPhase = AATurnSequence.nonCombatActions
        let turnManager = TurnManager(initialPhase: initialPhase)
        
        let validAction = NonCombatAction()
        XCTAssertTrue(turnManager.perform(action: validAction))
        
        // Creating an invalid action with a different sequence
        struct InvalidAction: TurnAction {
            typealias SequenceType = AATurnSequence
            let sequence: SequenceType = .combatActions
            func perform() {
                print("Performing Invalid Action")
            }
        }
        
        let invalidAction = InvalidAction()
        XCTAssertFalse(turnManager.perform(action: invalidAction))
    }
}
