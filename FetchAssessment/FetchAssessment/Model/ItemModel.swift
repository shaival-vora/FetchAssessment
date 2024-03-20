//
//  ItemModel.swift
//  FetchAssessment
//
//  Created by Shaival Vora on 3/20/24.
//

import Foundation

/// - This is the data model for fetch hiring API Call
/// - This conforms to the Codable Protocol which is the typeAlias for Decodable and Encodable protocols
struct ItemModel: Codable, Equatable {
     let id: Int
     let listId: Int
     let name: String?
}
