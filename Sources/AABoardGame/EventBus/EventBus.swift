import Combine
import Foundation

public enum EventBusError: Error {
    case eventNotFound(String)
    case cannotSubscribe
    case issueLocatingPublisher
}

public protocol Event {
    var id: UUID { get }
    var name: String { get }
}

extension Event {
    public var name: String { "\(Self.self)" }
}

public enum EventType: Codable {
    case endOfTurn(EndOfTurnEvent)
}

public class AnyEvent: Event, Codable {
    private let _getId: () -> UUID
    private let _getName: () -> String
    private let _encode: (Encoder) throws -> Void

    public var id: UUID {
        return _getId()
    }

    public init<E: Event & Codable>(_ event: E) {
        _getId = { event.id }
        _getName = { event.name }
        _encode = event.encode(to:)
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        
        _getId = { id }
        _getName = { name }

        // Add a more detailed decoding logic for different event types if needed
        _encode = { _ in }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

public struct EndOfTurnEvent: Event, Codable {
    public var id = UUID()
}

public struct BeginningOfTurnEvent: Event, Codable {
    public var id = UUID()
}

class EventBus {
    static let shared = EventBus()
    private var subscribers = [ObjectIdentifier: (any Event) -> Void]()
    private var subscriptions: [ObjectIdentifier: PassthroughSubject<Event, EventBusError>] = [:]
    
    private init() {}
    
    func publish(_ event: Event) {
        let key = ObjectIdentifier(type(of: event))
        subscriptions[key]?.send(event)
    }
    
    public func post(_ event: any Event) {
        let eventType = type(of: event)
        let key = ObjectIdentifier(eventType)
        
        for subscriber in subscribers where subscriber.key == key {
            subscriber.value(event)
        }
    }
    
    public func subscribe<E: Event>(_ eventType: E.Type) -> AsyncStream<E> {
        return AsyncStream { continuation in
            let key = ObjectIdentifier(eventType)
            
            subscribers[key] = { event in
                if let event = event as? E {
                    continuation.yield(event)
                }
            }
            
            continuation.onTermination = { @Sendable _ in }
        }
    }
    
    func subscribe<T: Event>(to eventType: T.Type) throws -> AnyPublisher<Event, EventBusError> {
        let key = ObjectIdentifier(eventType)
        debugPrint(key)
        
        guard subscriptions[key] != nil else {
            subscriptions[key] = PassthroughSubject<Event, EventBusError>()
            
            guard let publisher = subscriptions[key]?.eraseToAnyPublisher() else {
                throw EventBusError.issueLocatingPublisher
            }
            
            return publisher
        }
        
        guard let publisher = subscriptions[key]?.eraseToAnyPublisher() else {
            throw EventBusError.issueLocatingPublisher
        }
        
        return publisher.eraseToAnyPublisher()
    }
    
    public func send(_ event: Event) {
        let eventType = type(of: event)
        let key = ObjectIdentifier(eventType)
        let stream = subscribers[key]
        
        debugPrint("Sending event type: \(eventType) on identifier: \(key)")
        
        
    }
}
