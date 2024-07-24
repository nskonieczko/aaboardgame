public protocol Validator {
    func isValid<T: Operation>(from fromPlayer: Player, to toPlayer: Player, operation: T, board: Board) throws -> Bool
}

public typealias Operation = CaseIterable & Codable



