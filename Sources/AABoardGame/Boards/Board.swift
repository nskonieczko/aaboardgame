open class Board: BoardRequirement {
    open var territories: Set<Territory>
    
    public init(territories: Set<Territory>) {
        self.territories = territories
    }
    
    open func initializeBoard() {
        territories = []
    }
}
