//
//  RMEndpoint.swift
//  RickAndMorty
//
//  Created by lynnguyen on 02/04/2024.
//

import Foundation

/// Represents unique API Endpoint
@frozen enum RMEndpoint: String, Hashable, CaseIterable {
    // Endpoint to get character info
    case character
    // Endpoint to get location info
    case location
    // Endpoint to get episode info
    case episode
}
