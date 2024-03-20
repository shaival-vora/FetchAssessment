//
//  ItemViewModel.swift
//  FetchAssessment
//
//  Created by Shaival Vora on 3/20/24.
//

import Foundation

/// - ItemViewModel:- is the view model which handles the state and invokes the API call from the network service
/// - It uses ObservableObject: It allows the  views to observe changes made to the object's properties and react accordingly.

@MainActor
final class ItemViewModel: ObservableObject {
    
    /// State enum to represent different states of the view model.
    enum State {
        case notLoading
        case loading
        case success(data: [Int: [ItemModel]])
        case failed(error: Error)
    }
    
    /// Published property to expose the state to the views.
    @Published private (set) var state: State = .notLoading
    
    /// Network service used for fetching item data.
    private let service: ItemNetworkService
    
    /// Initializer to inject the network service dependency.
    init(service: ItemNetworkService) {
        self.service = service
    }
    
    /// Asynchronous function to fetch item data.
    func getItemData() async {
        self.state = .loading // Set the state to loading before fetching data.
        do {
            let data = try await service.fetchItemData()  // Fetch item data from the network service.
            self.processAndDisplayData(items: data)  // Process and display the fetched data.
        } catch {
            // If an error occurs during fetching, set the state to failed.
            self.state = .failed(error: error)
        }
    }
    
    /// Function to process and display the fetched data.
    /// - Parameter:- array of [ItemModel]
    func processAndDisplayData(items: [ItemModel]) {
        // Filter out items with nil or empty names
        let filteredItems = items.filter { $0.name != nil && !$0.name!.isEmpty }
        
        // Sort filtered items first by listId, then by name(ID) within each listId group
        let sortedItems = filteredItems.sorted { (first, second) -> Bool in
            // Using id value to sort the names based on count
            if first.listId == second.listId {
                return first.id < second.id
            } else {
                return first.listId < second.listId
            }
        }
        // Group sorted items by listId
        var groupedData: [Int: [ItemModel]] = [:]
        
        for item in sortedItems {
            if var group = groupedData[item.listId] {
                group.append(item)
                groupedData[item.listId] = group
            } else {
                groupedData[item.listId] = [item]
            }
        }
        // Update the state var to success to update the user UI with the correct data
        self.state = .success(data: groupedData)
        
    }
}
