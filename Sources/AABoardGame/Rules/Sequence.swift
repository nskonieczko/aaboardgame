public protocol Sequence {
    func next<T: TurnSequence>(after sequence: T) throws -> T
}

public protocol Order {
    func next(after order: Order) -> Order
}

/*
 
 In order to customize game, devs need to use these [Game Interface]
 
 */
public typealias GameOrder = CaseIterable & Codable & Order
public typealias TurnSequence = CaseIterable & Codable & Sequence & Equatable

public extension Sequence {
    func next<T>(after sequence: T) throws -> T where T : TurnSequence {
        let allCases = T.allCases
        
        guard let indexOfCurrentSequence = allCases.firstIndex(of: sequence),
                let defaultCase = allCases.first else {
            throw ValidationError.invalidOperation
        }
        
        let nextIndex = allCases.index(after: indexOfCurrentSequence)
        return nextIndex == allCases.endIndex ? defaultCase : allCases[nextIndex]
    }
}
