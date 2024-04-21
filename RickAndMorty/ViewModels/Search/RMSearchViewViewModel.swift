//
//  RMSearchViewViewModel.swift
//  RickAndMorty
//
//  Created by lynnguyen on 21/04/2024.
//

import Foundation
// Responsibilities
// - Show search Results
// - show no results view
// - kick off API requests

final class RMSearchViewViewModel {
    let config: RMSearchViewController.Config
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
}
