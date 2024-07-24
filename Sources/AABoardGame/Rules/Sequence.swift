internal protocol Sequence {
    associatedtype Element: Comparable & Codable
    var first: Element? { get }
}

public protocol Order {
    func next(after order: Order) -> Order
}

public protocol TurnSequence: CaseIterable, Equatable, Codable {
    func next() throws -> any TurnSequence
    func canPerform(action: any TurnAction) -> Bool
}

extension TurnSequence {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.equals(rhs)
    }
    
    public static func == (lhs: Self, rhs: any TurnAction) -> Bool {
        return lhs.equals(rhs)
    }
    
    public func equals(_ other: any TurnSequence) -> Bool {
        let myType = type(of: self)
        let otherType = type(of: other)
        return myType == otherType
    }
    
    public func equals(_ action: any TurnAction) -> Bool {
        let myType = type(of: self)
        let otherType = type(of: action.sequence)
        return myType == otherType
    }
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
