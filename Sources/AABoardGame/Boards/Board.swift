open class Board: AnyBoard {
    open var territories: Set<Territory>
    
    public init(territories: Set<Territory>) {
        self.territories = territories
    }
    
    open func initializeBoard() {
        territories = []
    }
}
