import Foundation

public class AAValidator: Validator {
    public func isValid<T: Operation>(from fromPlayer: Player, to toPlayer: Player, operation: T, board: Board) throws -> Bool {
        return false
    }
}
