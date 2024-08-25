import XCTest
import Testing
import Foundation

@testable import AABoardGame

// Define a sample EventModel for testing
struct TestModel: EventDataModelType {
    var id: UUID
    var data: String
}

// Define the test case class
final class EventBusTests: XCTestCase {
    let bus = EventBus.shared
    
    override func setUp() async throws {
        bus.subscribers.removeAll()
    }
    
    override func tearDown() async throws {
        bus.subscribers.removeAll()
    }
    
    func testSubscribeAndNotify() async throws {
        let expectationA = XCTestExpectation(description: "Received event for topic A")
        let expectationB = XCTestExpectation(description: "Received event for topic B")
        let dataPayloadA = try! JSONEncoder().encode("data for things A")
        let dataPayloadB = try! JSONEncoder().encode("data for things B")
        let dataA = AnyEncodable(data: dataPayloadA, type: String.self)!
        let dataB = AnyEncodable(data: dataPayloadB, type: String.self)!
        
        
        //        Task {
        let streams: AsyncStream<Event> = bus.subscribe(
            for: .action(.attack), .gameEvent(.newPhase)
        )
        
        Task {
            for await event in streams {
                switch event.topic {
                case .action(.attack):
                    XCTAssertEqual(event.data, dataA)
                    expectationB.fulfill()
                    
                case .gameEvent(.newPhase):
                    XCTAssertEqual(event.data, dataB)
                    expectationA.fulfill()
                    
                default:
                    XCTFail("This should never hit")
                }
            }
        }
        
        let eventA = Event(topic: .action(.attack), data: dataA)
        let eventB = Event(topic: .gameEvent(.newPhase), data: dataB)
        
        bus.notify(topic: .action(.attack), event: eventA)
        bus.notify(topic: .gameEvent(.newPhase), event: eventB)
        
        await fulfillment(of: [expectationA , expectationB], timeout: 5.0)
        //        wait(for: [expectationA, expectationB], timeout: 5.0)
    }
    
    func testPingPongMessages() async throws {
        let expectationA = XCTestExpectation(description: "Received event for topic A")
        let expectationB = XCTestExpectation(description: "Received event for topic B")
        
        let dataPayloadA = try JSONEncoder().encode("data for things A")
        let dataPayloadB = try JSONEncoder().encode("data for things B")
        
        let dataA = AnyEncodable(data: dataPayloadA, type: String.self)!
        let dataB = AnyEncodable(data: dataPayloadB, type: String.self)!
        
        let requestStream = EventBus.shared.subscribe(for: .request(.getTerritory(.unitedStates)))
        let responseStream = EventBus.shared.subscribe(for: .response(.territoryResponse(.unitedStates)))
        
        Task {
            for await event in requestStream {
                print("Received request event: \(event)")
                switch event.topic {
                case .request(.getTerritory(.unitedStates)):
                    XCTAssertEqual(event.data, dataA)
                    expectationA.fulfill()
                    
                    let responseEvent = Event(topic: .response(.territoryResponse(.unitedStates)), data: dataB)
                    EventBus.shared.notify(topic: .response(.territoryResponse(.unitedStates)), event: responseEvent)
                    
                default:
                    XCTFail("Unexpected event topic: \(event.topic)")
                }
            }
        }
        Task {
            for await event in responseStream {
                print("Received response event: \(event)")
                switch event.topic {
                case .response(.territoryResponse(.unitedStates)):
                    XCTAssertEqual(event.data, dataB)
                    expectationB.fulfill()
                    
                default:
                    XCTFail("Unexpected event topic: \(event.topic)")
                }
            }
        }
        
        let requestEvent = Event(topic: .request(.getTerritory(.unitedStates)), data: dataA)
        EventBus.shared.notify(topic: .request(.getTerritory(.unitedStates)), event: requestEvent)
        
        await fulfillment(of: [expectationA, expectationB], timeout: 5.0)
    }
    
    func testPingPongMessagesCurrentPhase() async throws {
        let expectationA = XCTestExpectation(description: "Received event for topic A")
        let expectationB = XCTestExpectation(description: "Received event for topic B")
        
        let dataPayloadA = try JSONEncoder().encode("data for things A")
        let dataPayloadB = try JSONEncoder().encode("data for things B")
        
        let dataA = AnyEncodable(data: dataPayloadA, type: String.self)!
        let dataB = AnyEncodable(data: dataPayloadB, type: String.self)!
        
        let requestStream = EventBus.shared.subscribe(for: .request(.getCurrentPhase))
        let responseStream = EventBus.shared.subscribe(for: .response(.currentPhaseResponse))
        
        Task {
            for await event in requestStream {
                XCTAssertEqual(event.data, dataA)
                expectationA.fulfill()
                
                let responseEvent = Event(topic: .response(.currentPhaseResponse), data: dataB)
                EventBus.shared.notify(topic: .response(.currentPhaseResponse), event: responseEvent)
            }
        }
        
        Task {
            for await event in responseStream {
                XCTAssertEqual(event.data, dataB)
                expectationB.fulfill()
            }
        }
        
        let requestEvent = Event(topic: .request(.getCurrentPhase), data: dataA)
        EventBus.shared.notify(topic: .request(.getCurrentPhase), event: requestEvent)
        
        await fulfillment(of: [expectationA, expectationB], timeout: 5.0)
    }
 
    
    func testCreateEventWithEncodable() {
        struct TestModel: Codable {
            let value: String
        }
        
        let topic = EventTopic.userInteraction(.selectToolbar)
        let model = TestModel(value: "Test Model")
        
        do {
            let event = try bus.createEvent(from: topic, type: TestModel.self, encodable: model)
            XCTAssertEqual(event.topic, topic)
            XCTAssertNotNil(event.data)
            let decodedModel = try JSONDecoder().decode(TestModel.self, from: event.data!.data)
            XCTAssertEqual(decodedModel.value, "Test Model")
        } catch {
            XCTFail("Event creation with encodable data failed: \(error)")
        }
    }
    
    func testNoSubscribers() {
        //        // Publish an event without any subscribers
        //        let event = Event(id: UUID(), topic: .endOfTurn, model: TestModel(id: UUID(), data: "No subscribers"))
        //
        //        // Ensure no subscribers exist
        //        XCTAssert(bus.subscribers[.endOfTurn]?.isEmpty ?? true)
        //
        //        bus.notify(eventType: .endOfTurn, event: event)
        //
        //        // Still no subscribers after notification
        //        XCTAssert(bus.subscribers[.endOfTurn]?.isEmpty ?? true)
    }
    
    func testSubscribeAndNotifyMultipleTopics() async throws {
        // Create expectations
        //        let expectationA = XCTestExpectation(description: "Received event for topic endOfTurn")
        //        let expectationB = XCTestExpectation(description: "Received event for topic beginningOfTurn")
        //        let stream: AsyncEventStream<TestModel> = bus.subscribe(for: .endOfTurn, .beginningOfTurn)
        //
        //        // Check for events on the combined stream
        //        Task {
        //            for await event in stream {
        //                switch event.topic {
        //                case .endOfTurn:
        //                    XCTAssertEqual(event.model.data, "Data for endOfTurn")
        //                    expectationA.fulfill()
        //
        //                case .beginningOfTurn:
        //                    XCTAssertEqual(event.model.data, "Data for beginningOfTurn")
        //                    expectationB.fulfill()
        //                }
        //            }
        //        }
        //
        //        // Publish events
        //        let eventA = Event(id: UUID(), topic: .endOfTurn, model: TestModel(id: UUID(), data: "Data for endOfTurn"))
        //        let eventB = Event(id: UUID(), topic: .beginningOfTurn, model: TestModel(id: UUID(), data: "Data for beginningOfTurn"))
        //
        //        bus.notify(eventType: .endOfTurn, event: eventA)
        //        bus.notify(eventType: .beginningOfTurn, event: eventB)
        //
        //        // Wait for expectations
        //        await fulfillment(of: [expectationA, expectationB], timeout: 2.0)
    }
    
    func testTermination() async throws {
        //        let subscriptionTask = Task {
        //            _ = bus.subscribe(for: .endOfTurn) as AsyncEventStream<TestModel>
        //        }
        //
        //        await subscriptionTask.result
        //
        //        // Ensure subscriber is added
        //        XCTAssertFalse(bus.subscribers[.endOfTurn].isNilOrEmpty)
        //
        //        // Cancel the subscription task to trigger termination
        //        subscriptionTask.cancel()
        //
        //        try await Task.sleep(nanoseconds: 500_000_000)
        //
        //        // Ensure subscriber is removed
        //        #expect(bus.subscribers[.endOfTurn].isNilOrEmpty)
        //        #expect(subscriptionTask.isCancelled)
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}


/*
 final class EventBusTests: XCTestCase {
 let expectedEndOfTurnEvent = EndOfTurnModel()
 let expectedBeginningEvent = BeginningOfTurnModel()
 
 var eventBus: EventBus { EventBus.shared }
 
 var a = Territory(name: "A", industrialOutput: 1)
 var b = Territory(name: "B", industrialOutput: 1)
 var c = Territory(name: "C", industrialOutput: 1)
 var d = Territory(name: "D", industrialOutput: 1)
 
 func testSingleEventTypeSubscription() {
 let expectation = self.expectation(description: "Subscriber should receive the event")
 let endOfTurnModel = EndOfTurnModel()
 let event = Event(id: UUID(), model: endOfTurnModel)
 
 let stream: AsyncStream<Event<EndOfTurnModel>> = eventBus.subscribe(for: .endOfTurn)
 
 Task {
 for await receivedEvent in stream {
 XCTAssertEqual(receivedEvent.model.id, endOfTurnModel.id)
 expectation.fulfill()
 break
 }
 }
 
 eventBus.notify(eventType: .endOfTurn, event: event)
 
 waitForExpectations(timeout: 1, handler: nil)
 }
 
 func test_subscribeAndListen() throws {
 let expectation = XCTestExpectation(description: "Bus test")
 expectation.expectedFulfillmentCount = 3
 
 let stream: AsyncEventStream<EndOfTurnModel> = eventBus.subscribe(for: .endOfTurn)
 let beginningStream: AsyncEventStream<BeginningOfTurnModel> = eventBus.subscribe(for: .beginningOfTurn)
 
 let endOfTurnModel = EndOfTurnModel()
 let event = Event(id: UUID(), model: endOfTurnModel)
 
 Task {
 for await event in stream {
 debugPrint("Received event: \(event.id)")
 #expect(event.id == expectedEndOfTurnEvent.id)
 #expect(event.model == endOfTurnModel)
 
 expectation.fulfill()
 }
 
 for await event in beginningStream {
 debugPrint("Received event: \(event.id)")
 }
 }
 
 Task {
 eventBus.notify(eventType: .beginningOfTurn, event: event)
 eventBus.notify(eventType: .endOfTurn, event: event)
 eventBus.notify(eventType: .endOfTurn, event: event)
 
 DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1.0) {
 self.eventBus.notify(eventType: .endOfTurn, event: event)
 }
 }
 
 wait(for: [expectation], timeout: 5.0)
 }
 
 func testMultipleEventTypeSubscription() {
 let endOfTurnExpectation = self.expectation(description: "Subscriber should receive EndOfTurn event")
 let beginningOfTurnExpectation = self.expectation(description: "Subscriber should receive BeginningOfTurn event")
 
 let endOfTurnModel = EndOfTurnModel()
 let beginningOfTurnModel = BeginningOfTurnModel()
 
 let endOfTurnEvent = Event(id: UUID(), model: endOfTurnModel)
 let beginningOfTurnEvent = Event(id: UUID(), model: beginningOfTurnModel)
 
 let stream = eventBus.subscribe(for: .endOfTurn, .beginningOfTurn)
 
 Task {
 var receivedEndOfTurn = false
 var receivedBeginningOfTurn = false
 
 for await receivedEvent in stream {
 if let endOfTurn = receivedEvent.model as? EndOfTurnModel {
 XCTAssertEqual(endOfTurn.id, endOfTurnModel.id)
 receivedEndOfTurn = true
 }
 if let beginningOfTurn = receivedEvent.model as? BeginningOfTurnModel {
 XCTAssertEqual(beginningOfTurn.id, beginningOfTurnModel.id)
 receivedBeginningOfTurn = true
 }
 if receivedEndOfTurn && receivedBeginningOfTurn {
 endOfTurnExpectation.fulfill()
 beginningOfTurnExpectation.fulfill()
 break
 }
 }
 }
 
 eventBus.notify(eventType: .endOfTurn, event: endOfTurnEvent)
 eventBus.notify(eventType: .beginningOfTurn, event: beginningOfTurnEvent)
 
 waitForExpectations(timeout: 1, handler: nil)
 }
 
 //    func test_subscribeAndListen_multiple() throws {
 //        let expectation = XCTestExpectation(description: "Bus test")
 //        expectation.expectedFulfillmentCount = 3
 //
 //        let stream: AsyncStream<Event> = eventBus.subscribe(.endOfTurn(expectedEvent))
 //
 //        Task {
 //            for await event in stream {
 //                debugPrint("Received event: \(event.name)")
 //                #expect(event.id == expectedEvent.id)
 //
 //                expectation.fulfill()
 //            }
 //        }
 //
 //        Task {
 //            eventBus.post(expectedBeginningEvent)
 //            eventBus.post(expectedEvent)
 //
 //            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 4.0) {
 //                self.eventBus.post(self.expectedEvent)
 //            }
 //        }
 //
 //        wait(for: [expectation], timeout: 5.0)
 //    }
 
 func test_territoryEncoder() throws {
 struct TerritoryResponse: Codable {
 let territories: [Territory]
 }
 
 // A -> B, B -> C, B -> D, C -> D
 a.adjacentTerritories = [b.identifier]
 b.adjacentTerritories = [c.identifier, d.identifier]
 c.adjacentTerritories = [b.identifier, d.identifier]
 d.adjacentTerritories = [b.identifier, c.identifier]
 
 let dataArray = TerritoryResponse(territories: [a, b, c, d])
 
 let jsonEncoder = JSONEncoder()
 let data = try jsonEncoder.encode(dataArray)
 
 if let json = String(data: data, encoding: .utf8) {
 print(json)
 }
 
 try? data.write(to: .documentsDirectory, options: .atomic)
 }
 }
 */

final class TerritoryTests {
    let json = """
    {
        "territories": [
            {
                "industrialOutput": 1,
                "name": "A",
                "units": [],
                "adjacentTerritories": [
                    "DFAB231B-9BB2-4B26-BE31-8EE1F52D54BC"
                ],
                "identifier": "71470B6B-EFDA-4104-A940-5B72DFCB955D"
            },
            {
                "units": [],
                "industrialOutput": 1,
                "adjacentTerritories": [
                    "67C9AC91-B38A-4200-A046-BC62D39B2DCB",
                    "DEE573B7-5FE3-487B-9D93-685567426DA3"
                ],
                "identifier": "DFAB231B-9BB2-4B26-BE31-8EE1F52D54BC",
                "name": "B"
            },
            {
                "adjacentTerritories": [
                    "DFAB231B-9BB2-4B26-BE31-8EE1F52D54BC",
                    "DEE573B7-5FE3-487B-9D93-685567426DA3"
                ],
                "units": [],
                "name": "C",
                "identifier": "67C9AC91-B38A-4200-A046-BC62D39B2DCB",
                "industrialOutput": 1
            },
            {
                "units": [],
                "name": "D",
                "identifier": "DEE573B7-5FE3-487B-9D93-685567426DA3",
                "adjacentTerritories": [
                    "DFAB231B-9BB2-4B26-BE31-8EE1F52D54BC",
                    "67C9AC91-B38A-4200-A046-BC62D39B2DCB"
                ],
                "industrialOutput": 1
            }
        ]
    }
    """.data(using: .utf8)!
    var a = Territory(country: .unitedStates, industrialOutput: 1)
    var b = Territory(country: .unitedStates, industrialOutput: 1)
    var c = Territory(country: .unitedStates, industrialOutput: 1)
    var d = Territory(country: .unitedStates, industrialOutput: 1)
    
    struct TerritoryResponse: Codable {
        let territories: [Territory]
    }
    
    @Test("Builder")
    func territoryDecoder() {
        let jsonDecoder = JSONDecoder()
        let response = try? jsonDecoder.decode(TerritoryResponse.self, from: json)
        #expect(response != nil)
        #expect(response?.territories.count == 4)
    }
    
    @Test("Encode")
    func territoryEncoder() throws {
        
        // A -> B, B -> C, B -> D, C -> D
        a.adjacentTerritories = [b.identifier]
        b.adjacentTerritories = [c.identifier, d.identifier]
        c.adjacentTerritories = [b.identifier, d.identifier]
        d.adjacentTerritories = [b.identifier, c.identifier]
        
        let dataArray = TerritoryResponse(territories: [a, b, c, d])
        
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(dataArray)
        
        if let json = String(data: data, encoding: .utf8) {
            print(json)
        }
        
        FileManager.default.createFile(atPath: "/tmp/test.json", contents: data)
    }
}


class EventBus2Tests: XCTestCase {
    var eventBus: EventBus!

    override func setUp() {
        super.setUp()
        eventBus = EventBus.shared
    }

    func testEventTopicNotification() async throws {
        let expectationA = XCTestExpectation(description: "Received event for topic A")
        let expectationB = XCTestExpectation(description: "Received event for topic B")
        
        // Prepare data payloads
        let dataPayloadA = try JSONEncoder().encode("data for things A")
        let dataPayloadB = try JSONEncoder().encode("data for things B")
        
        // Create event data
        let dataA = AnyEncodable(data: dataPayloadA, type: String.self)!
        let dataB = AnyEncodable(data: dataPayloadB, type: String.self)!
        
        // Create request and response streams
        let requestStream = eventBus.subscribe(for: .request(.getTerritory(.unitedStates)))
        let responseStream = eventBus.subscribe(for: .response(.territoryResponse(.unitedStates)))
        
        // Task to handle event reception
        Task {
            // Handle request event
            for await event in requestStream {
                switch event.topic {
                case .request(.getTerritory(.unitedStates)):
                    XCTAssertEqual(event.data, dataA)
                    expectationA.fulfill() // Fulfill expectation for request event
                    
                    // Create and notify response event
                    let responseEvent = Event(
                        topic: .response(.territoryResponse(.unitedStates)),
                        data: dataB
                    )
                    eventBus.notify(topic: .response(.territoryResponse(.unitedStates)), event: responseEvent)
                    
                default:
                    XCTFail("Unexpected event topic")
                }
            }
            
            // Handle response event
            for await event in responseStream {
                switch event.topic {
                case .response(.territoryResponse(.unitedStates)):
                    XCTAssertEqual(event.data, dataB)
                    expectationB.fulfill() // Fulfill expectation for response event
                    
                default:
                    XCTFail("Unexpected event topic")
                }
            }
        }
        
        // Create and notify request event
        let requestEvent = Event(
            topic: .request(.getTerritory(.unitedStates)),
            data: dataA
        )
        eventBus.notify(topic: .request(.getTerritory(.unitedStates)), event: requestEvent)
        
        // Wait for expectations
        await fulfillment(of: [expectationA, expectationB], timeout: 5.0)
    }
}
