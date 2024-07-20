import Combine
import Foundation

public enum EventBusError: Error {
    case eventNotFound(String)
    case cannotSubscribe
    case issueLocatingPublisher
}

public enum EventType: Codable {
    case endOfTurn
    case beginningOfTurn
}

public protocol IdentifiableEvent {
    var id: UUID { get }
}

public typealias Eventable = IdentifiableEvent & Codable & Identifiable & Sendable
public typealias AsyncEventStream<T: Eventable> = AsyncStream<Event<T>>

public struct Event<T: Eventable>: Eventable {
    public var id: UUID
    public var model: T
}

public class EventBus {
    static let shared = EventBus()
    
    private init() { }
    
    private var subscribers: [EventType: [(any Eventable) -> Void]] = [:]
    
    public func subscribe<T: Eventable>(for eventTypes: EventType...) -> AsyncEventStream<T> {
        return AsyncStream { continuation in
            for eventType in eventTypes {
                if subscribers[eventType] == nil {
                    subscribers[eventType] = []
                }
            
                subscribers[eventType]?.append { event in
                    if let event = event as? Event<T> {
                        continuation.yield(event)
                    }
                }
            }
            
            continuation.onTermination = { @Sendable _ in }
        }
    }
    
    public func notify<T: Eventable>(eventType: EventType, event: Event<T>) {
        guard let eventSubscribers = subscribers[eventType] else {
            return
        }
        
        for subscriber in eventSubscribers {
            subscriber(event)
        }
    }
}
