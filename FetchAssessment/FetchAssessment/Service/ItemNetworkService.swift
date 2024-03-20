//
//  ItemNetworkService.swift
//  FetchAssessment
//
//  Created by Shaival Vora on 3/20/24.
//

import Foundation

protocol ItemNetworkServiceProtocol {
    func fetchItemData() async throws -> [ItemModel]
}


// Network Service Structure: It promotes a clean separation of concerns by isolating networking code from SwiftUI views and view models, thus improving code readability, maintainability, and testability.

/// - ItemNetworkService class makes the API call to get the details about the hiringAPI data
struct ItemNetworkService: ItemNetworkServiceProtocol {
    
    /// Enum to represent different errors that can occur during network requests.
    enum ItemError: Error {
        case failed
        case failedToDecode
        case invalidStatusCode
    }
    
    /// Function to fetch item data asynchronously from the API.
    func fetchItemData() async throws -> [ItemModel] {
        //create url from the URL string
        let defaultUrlString: String = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
      
        guard let url = URL(string: defaultUrlString) else {
            throw ItemError.failed
        }
        
        // Fetch the data from the API
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check if the response status code is valid (200).
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw ItemError.invalidStatusCode
        }
        
        // decode the data using JSON decoder
        if let decodedResponse = try? JSONDecoder().decode([ItemModel].self, from: data) {
            return  decodedResponse
        } else {
            throw ItemError.failedToDecode
        }
    }
    
}
