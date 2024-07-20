import Foundation

public struct AnyUnit: Unit {
    private let _hash: (inout Hasher) -> Void
    private let _isEqual: (Any) -> Bool
    private let _type: UnitType
    private let _encode: (Encoder) throws -> Void
    
    public var type: UnitType {
        return _type
    }
    
    public init<U: Unit>(_ unit: U) {
        _hash = unit.hash(into:)
        _isEqual = { $0 as? U == unit }
        _type = unit.type
        _encode = unit.encode(to:)
    }
    
    public func hash(into hasher: inout Hasher) {
        _hash(&hasher)
    }
    
    public static func ==(lhs: AnyUnit, rhs: AnyUnit) -> Bool {
        return lhs._isEqual(rhs) && lhs.type == rhs.type
    }
    
    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(UnitType.self, forKey: .type)
        
        switch type {
        case .infantry:
            self.init(try Infantry(from: decoder))
        case .artillery:
            self.init(try Artillery(from: decoder))
        case .aaGun:
            self.init(try AAGun(from: decoder))
        case .tank:
            self.init(try Tank(from: decoder))
        case .fighter:
            self.init(try Fighter(from: decoder))
        case .tacticalBomber:
            self.init(try TacticalBomber(from: decoder))
        case .strategicBomber:
            self.init(try StrategicBomber(from: decoder))
        case .transport:
            self.init(try Transport(from: decoder))
        case .submarine:
            self.init(try Submarine(from: decoder))
        case .destroyer:
            self.init(try Destroyer(from: decoder))
        case .cruiser:
            self.init(try Cruiser(from: decoder))
        case .battleship:
            self.init(try Battleship(from: decoder))
        case .aircraftCarrier:
            self.init(try AircraftCarrier(from: decoder))
        case .navalBase:
            self.init(try NavalBase(from: decoder))
        case .airBase:
            self.init(try AirBase(from: decoder))
        case .minorIndustrialComplex:
            self.init(try MinorIndustrialComplex(from: decoder))
        case .majorIndustrialComplex:
            self.init(try MajorIndustrialComplex(from: decoder))
        case .minorToMajorIndustrialComplexUpgrade:
            self.init(try MinorToMajorIndustrialComplexUpgrade(from: decoder))
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}



public protocol Unit: Hashable, Codable {
    var type: UnitType { get }
    var attack: Double { get }
    var defense: Double { get }
    var move: Double { get }
    var cost: Double { get }
}

public extension Unit {
    var unitClass: UnitClass { type.unitClass }
    var attack: Double { type.attack }
    var defense: Double { type.defense }
    var move: Double { type.move }
    var cost: Double { type.cost }
}

public enum UnitClass: String, Codable, Hashable {
    case ground
    case air
    case naval
    case facility
}

public enum UnitType: String, Hashable, Equatable, Codable {
    case infantry
    case artillery
    case aaGun
    case tank
    case fighter
    case tacticalBomber
    case strategicBomber
    case transport
    case submarine
    case destroyer
    case cruiser
    case battleship
    case aircraftCarrier
    case navalBase
    case airBase
    case minorIndustrialComplex
    case majorIndustrialComplex
    case minorToMajorIndustrialComplexUpgrade
    
    var attack: Double {
        switch self {
        case .infantry: return 1.0
        case .artillery: return 2.0
        case .aaGun: return 0.0 // n/a
        case .tank: return 3.0
        case .fighter: return 3.0
        case .tacticalBomber: return 3.0
        case .strategicBomber: return 2.0 // two at 2, for 1 round
        case .transport: return 0.0 // n/a
        case .submarine: return 2.0
        case .destroyer: return 2.0
        case .cruiser: return 3.0
        case .battleship: return 4.0
        case .aircraftCarrier: return 0.0 // n/a
        case .navalBase: return 0.0 // n/a
        case .airBase: return 0.0 // n/a
        case .minorIndustrialComplex: return 0.0 // n/a
        case .majorIndustrialComplex: return 0.0 // n/a
        case .minorToMajorIndustrialComplexUpgrade: return 0.0 // n/a
        }
    }
    
    var defense: Double {
        switch self {
        case .infantry: return 2.0
        case .artillery: return 2.0
        case .aaGun: return 0.0 // n/a
        case .tank: return 3.0
        case .fighter: return 4.0
        case .tacticalBomber: return 3.0
        case .strategicBomber: return 1.0
        case .transport: return 1.0 // 0 / 1*
        case .submarine: return 1.0
        case .destroyer: return 2.0
        case .cruiser: return 3.0 // 3 / 4*
        case .battleship: return 4.0 // 4 / 2*
        case .aircraftCarrier: return 2.0 // 2 / 1*
        case .navalBase: return 0.0 // n/a
        case .airBase: return 0.0 // n/a
        case .minorIndustrialComplex: return 0.0 // n/a
        case .majorIndustrialComplex: return 0.0 // n/a
        case .minorToMajorIndustrialComplexUpgrade: return 0.0 // n/a
        }
    }
    
    var move: Double {
        switch self {
        case .infantry: return 1.0
        case .artillery: return 1.0
        case .aaGun: return 1.0
        case .tank: return 2.0
        case .fighter: return 4.0
        case .tacticalBomber: return 4.0
        case .strategicBomber: return 5.0
        case .transport: return 2.0
        case .submarine: return 2.0
        case .destroyer: return 2.0
        case .cruiser: return 2.0
        case .battleship: return 2.0
        case .aircraftCarrier: return 2.0
        case .navalBase: return 0.0 // n/a
        case .airBase: return 0.0 // n/a
        case .minorIndustrialComplex: return 0.0 // n/a
        case .majorIndustrialComplex: return 0.0 // n/a
        case .minorToMajorIndustrialComplexUpgrade: return 0.0 // n/a
        }
    }
    
    var cost: Double {
        switch self {
        case .infantry: return 3.0
        case .artillery: return 4.0
        case .aaGun: return 5.0
        case .tank: return 6.0
        case .fighter: return 10.0
        case .tacticalBomber: return 11.0
        case .strategicBomber: return 12.0
        case .transport: return 7.0
        case .submarine: return 6.0
        case .destroyer: return 8.0
        case .cruiser: return 12.0
        case .battleship: return 20.0
        case .aircraftCarrier: return 16.0
        case .navalBase: return 15.0
        case .airBase: return 15.0
        case .minorIndustrialComplex: return 12.0
        case .majorIndustrialComplex: return 30.0
        case .minorToMajorIndustrialComplexUpgrade: return 20.0
        }
    }
    
    var unitClass: UnitClass {
        switch self {
        case .infantry, .artillery, .aaGun, .tank:
            return .ground
        case .fighter, .tacticalBomber, .strategicBomber:
            return .air
        case .transport, .submarine, .destroyer, .cruiser, .battleship, .aircraftCarrier:
            return .naval
        case .navalBase, .airBase, .minorIndustrialComplex, .majorIndustrialComplex, .minorToMajorIndustrialComplexUpgrade:
            return .facility
        }
    }
}

public struct Infantry: Unit {
    public var type: UnitType = .infantry
}

public struct Artillery: Unit {
    public var type: UnitType = .artillery
}

public struct AAGun: Unit {
    public var type: UnitType = .aaGun
}

public struct Tank: Unit {
    public var type: UnitType = .tank
}

public struct Fighter: Unit {
    public var type: UnitType = .fighter
}

public struct TacticalBomber: Unit {
    public var type: UnitType = .tacticalBomber
}

public struct StrategicBomber: Unit {
    public var type: UnitType = .strategicBomber
}

public struct Transport: Unit {
    public var type: UnitType = .transport
}

public struct Submarine: Unit {
    public var type: UnitType = .submarine
}

public struct Destroyer: Unit {
    public var type: UnitType = .destroyer
}

public struct Cruiser: Unit {
    public var type: UnitType = .cruiser
}

public struct Battleship: Unit {
    public var type: UnitType = .battleship
}

public struct AircraftCarrier: Unit {
    public var type: UnitType = .aircraftCarrier
}

public struct NavalBase: Unit {
    public var type: UnitType = .navalBase
}

public struct AirBase: Unit {
    public var type: UnitType = .airBase
}

public struct MinorIndustrialComplex: Unit {
    public var type: UnitType = .minorIndustrialComplex
}

public struct MajorIndustrialComplex: Unit {
    public var type: UnitType = .majorIndustrialComplex
}

public struct MinorToMajorIndustrialComplexUpgrade: Unit {
    public var type: UnitType = .minorToMajorIndustrialComplexUpgrade
}
