internal protocol Sequence {
    associatedtype Element: Comparable & Codable
    var first: Element? { get }
}

public protocol Order {
    func next(after order: Order) -> Order
}

public protocol TurnSequence: CaseIterable, Equatable, Codable, Sendable {
    func next() throws -> any TurnSequence
//    func canPerform(action: any TurnActionType) -> Bool
}

/*
 
 In order to customize game, devs need to use these [Game Interface]
 
 */

public typealias GameOrder = CaseIterable & Codable & Order

extension TurnSequence {
    public var first: (any TurnSequence)? {
        Self.allCases.first
    }
    
    public func next() throws -> any TurnSequence {
        let allCases = Self.allCases
        
        guard let indexOfCurrentSequence = allCases.firstIndex(of: self),
              let defaultCase = allCases.first else {
            throw ValidationError.invalidOperation
        }
        
        let nextIndex = allCases.index(after: indexOfCurrentSequence)
        
        let nextSequence = allCases[nextIndex]
        return nextIndex == allCases.endIndex ? defaultCase : nextSequence
    }
}
