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
    
    private var optionMap: [RMSearchInputViewViewModel.DynamicOption: String] = [:]
    
    private var searchText = ""
    
    private var optionMapUpdateBlock: (((RMSearchInputViewViewModel.DynamicOption, String)) -> Void)?
    
    private var searchResultHandler: (() -> Void)?
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
    
    // MARK: - Public
    public func registerSearchResultsHandler(_ block: @escaping () -> Void) {
        searchResultHandler = block
    }
    
    public func set(quety text: String) {
        searchText = text
    }
    
    public func set(value: String, for option: RMSearchInputViewViewModel.DynamicOption) {
        optionMap[option] = value
        let tuple = (option, value)
        optionMapUpdateBlock?(tuple)
    }
    
    public func registerOptionChangeBlock(
        _ block: @escaping ((RMSearchInputViewViewModel.DynamicOption, String)) -> Void
    ) {
        optionMapUpdateBlock = block
    }
    
    public func executeSearch() {
        // Create request based on filters
        //https://rickandmortyapi.com/api/character/?name=rick&status=alive
        searchText = "Rick"
        
        // Build arguments
        var queryParams: [URLQueryItem] = [
            URLQueryItem(name: "name", value: searchText)
        ]
        
        // Add options
        queryParams.append(
            contentsOf: optionMap.enumerated().compactMap({ _, value in
                let key: RMSearchInputViewViewModel.DynamicOption = value.key
                let value: String = value.value
                return URLQueryItem(name: key.queryAgurment, value: value)
            })
        )
        
        // Create request
        var request = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: queryParams
        )
        
        // Send API call
        RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self) { result in
            switch result {
            case .success(let model):
                print("Search results found: \(model.results.count)")
            case .failure:
                break
            }
        }

        // Notify view of results, no results or error
    }
}
