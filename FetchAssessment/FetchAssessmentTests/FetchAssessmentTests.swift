//
//  FetchAssessmentTests.swift
//  FetchAssessmentTests
//
//  Created by Shaival Vora on 3/20/24.
//

import XCTest
@testable import FetchAssessment

final class FetchAssessmentTests: XCTestCase {
    // Mock ItemNetworkServiceProtocol for testing
    class MockItemNetworkService: ItemNetworkServiceProtocol {
        var shouldThrowError = false
        func fetchItemData() async throws -> [ItemModel] {
            // Return sample data for testing
            if shouldThrowError {
                throw NSError(domain: "MockErrorDomain", code: 123, userInfo: nil) // Simulated error
            }
            return [ItemModel(id: 1, listId: 1, name: "Item 1"),
                    ItemModel(id: 2, listId: 1, name: "Item 2"),
                    ItemModel(id: 3, listId: 2, name: "Item 3")]
        }
        
        func fetchItemDataWithNillAndEmptyName() async throws -> [ItemModel] {
                   // Return sample data for testing
                   return [ItemModel(id: 1, listId: 1, name: "Item 1"),
                           ItemModel(id: 3, listId: 1, name: "Item 3"),
                           ItemModel(id: 2, listId: 2, name: "Item 2"),
                           ItemModel(id: 4, listId: 2, name: nil),
                           ItemModel(id: 5, listId: 3, name: "")]
               }
    }
    
    // Test successful data fetching
    func testFetchItemData_Success() async throws {
        let viewModel = await ItemViewModel(service: MockItemNetworkService())
        await viewModel.getItemData()
        
        // Assert that state is now success and contains expected data
        switch await viewModel.state {
        case .success(let data):
            XCTAssertEqual(data.count, 2) // Expecting 2 list ids
            XCTAssertEqual(data[1], [ItemModel(id: 1, listId: 1, name: "Item 1"),
                                     ItemModel(id: 2, listId: 1, name: "Item 2")])
            XCTAssertEqual(data[2], [ItemModel(id: 3, listId: 2, name: "Item 3")])
        default:
            XCTFail("Expected state to be success")
        }
    }
    
    // Test error handling
    func testFetchItemData_Failure() async throws {
        let mockService = MockItemNetworkService()
        mockService.shouldThrowError = true // Simulate error
        
        let viewModel = await ItemViewModel(service: mockService)
        await viewModel.getItemData()
        
        // Assert that state is now failed
        switch await viewModel.state {
        case .failed:
            XCTAssertTrue(true) // Test passed if state is failed
        default:
            XCTFail("Expected state to be failed")
        }
    }
    
     func testProcessAndDisplayData() async throws {
            let viewModel = await ItemViewModel(service: MockItemNetworkService())
            
            // Call the method
         await viewModel.processAndDisplayData(items: try! MockItemNetworkService().fetchItemDataWithNillAndEmptyName())
            
            // Assert that state is now success and contains expected grouped data
         switch await viewModel.state {
            case .success(let data):
            // Check if all items with nil or empty names are filtered out
            XCTAssertNil(data[3], "List ID 3 should not exist in grouped data due to empty name")
            // ListId with 2 had two items but since in one item the name is nil so it will be filtered out and therefore there is only item left with listId 2
            XCTAssertEqual(data[2], [ItemModel(id: 2, listId: 2, name: "Item 2")])
             
             
            // Check if items are sorted correctly
            XCTAssertEqual(data[1]?.map({ $0.id }), [1, 3], "Items for list ID 1 should be sorted correctly")
            XCTAssertEqual(data[2]?.map({ $0.id }), [2], "Items for list ID 2 should be sorted correctly")
            default:
                XCTFail("Expected state to be success")
            }
        }



}
