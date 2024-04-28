//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by lynnguyen on 28/04/2024.
//

import Foundation

enum RMSearchResultViewModel {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}