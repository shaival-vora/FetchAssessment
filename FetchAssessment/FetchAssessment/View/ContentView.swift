//
//  ContentView.swift
//  FetchAssessment
//
//  Created by Shaival Vora on 3/20/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ItemViewModel(service: ItemNetworkService())
    
    var body: some View {
        VStack {
            // Switch on ViewModel state For now I have kept a progressview for loading state which is when the API call is being made and on success state it will display the list as required and I have kept a Empty view for rest of the states
            switch viewModel.state {
            case .loading:
                // If ViewModel is in loading state, show ProgressView
                ProgressView()
            case .success(let itemData):
                // If ViewModel is in success state, display fetched data in a List
                List {
                    ForEach(itemData.sorted(by: {$0.key < $1.key}), id: \.key) { key, items in
                        Section(header: Text("List ID: \(key), Item count: \(items.count)")) {
                            ForEach(items, id: \.id) { item in
                                Text("Name: \(item.name ?? "")")
                            }
                        }
                    }
                }
            default:
                // If ViewModel is in any other state, display EmptyView
                EmptyView()
            }

        }
        .task { // Asynchronously fetch item data when the view appears
            await viewModel.getItemData()
        }
    }
    
}

#Preview {
    ContentView()
}
