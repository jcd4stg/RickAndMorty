//
//  RMCharacterStatus.swift
//  RickAndMorty
//
//  Created by lynnguyen on 02/04/2024.
//

import Foundation

enum RMCharacterStatus: String, Codable {
    /// Alive', 'Dead' or 'unknown
    case alive = "Alive"
    case dead = "Dead"
    case `unknown` = "unknown"
}
