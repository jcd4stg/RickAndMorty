//
//  RMGetLocationsResponse.swift
//  RickAndMorty
//
//  Created by lynnguyen on 20/04/2024.
//

import Foundation

struct RMGetLocationsResponse: Codable {
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    let info:  Info
    let results: [RMLocation]
}
