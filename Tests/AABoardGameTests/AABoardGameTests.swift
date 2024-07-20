import XCTest
import Testing
import Foundation

@testable import AABoardGame

final class EventBusTests: XCTestCase {
    let expectedEvent = EndOfTurnEvent()
    let expectedBeginningEvent = EndOfTurnEvent()
    
    var eventBus: EventBus { EventBus.shared }
    
    var a = Territory(name: "A", industrialOutput: 1)
    var b = Territory(name: "B", industrialOutput: 1)
    var c = Territory(name: "C", industrialOutput: 1)
    var d = Territory(name: "D", industrialOutput: 1)
    
    func test_subscribeAndListen() throws {
        let expectation = XCTestExpectation(description: "Bus test")
        expectation.expectedFulfillmentCount = 3
        
        let stream = eventBus.subscribe(EndOfTurnEvent.self)
        let beginningStream = eventBus.subscribe(BeginningOfTurnEvent.self)
        
        Task {
            for await event in stream {
                debugPrint("Received event: \(event.name)")
                #expect(event.id == expectedEvent.id)
                
                expectation.fulfill()
            }
            
            for await event in beginningStream {
                debugPrint("Received event: \(event.name)")
                XCTFail("should not get this")
            }
        }
        
        Task {
            eventBus.post(expectedBeginningEvent)
            eventBus.post(expectedEvent)
            
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 4.0) {
                self.eventBus.post(self.expectedEvent)
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
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
    var a = Territory(name: "A", industrialOutput: 1)
    var b = Territory(name: "B", industrialOutput: 1)
    var c = Territory(name: "C", industrialOutput: 1)
    var d = Territory(name: "D", industrialOutput: 1)
    
    struct TerritoryResponse: Codable {
        let territories: [Territory]
    }
    
    @Test("Builder")
    func territoryDecoder() {
        let jsonDecoder = JSONDecoder()
        let response = try? jsonDecoder.decode(TerritoryResponse.self, from: json)
        #expect(response != nil)
        #expect(response?.territories.count == 2)
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
