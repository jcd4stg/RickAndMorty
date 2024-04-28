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
    
    private var searchResultHandler: ((RMSearchResultViewModel) -> Void)?
    
    private var noResultHandler: (() -> Void)?

    private var searchResultModel: Codable?
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
    
    // MARK: - Public
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
    
    public func registerSearchResultsHandler(_ block: @escaping (RMSearchResultViewModel) -> Void) {
        searchResultHandler = block
    }
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        noResultHandler = block
    }
    public func executeSearch() {
        // Create request based on filters
        //https://rickandmortyapi.com/api/character/?name=rick&status=alive
                    
        // Build arguments
        var queryParams: [URLQueryItem] = [
            URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        ]
        
        // Add options
        queryParams.append(
            contentsOf: optionMap.enumerated().compactMap({ _, element in
                let key: RMSearchInputViewViewModel.DynamicOption = element.key
                let value: String = element.value
                return URLQueryItem(name: key.queryAgurment, value: value)
            })
        )
        
        // Create request
        let request = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: queryParams
        )
        
        switch config.type.endpoint {
        case .character:
            makeSearchAPICall(RMGetAllCharactersResponse.self, request: request)
        case .location:
            makeSearchAPICall(RMGetLocationsResponse.self, request: request)
        case .episode:
            makeSearchAPICall(RMGetAllEpisodesResponse.self, request: request)
        }
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: RMRequest) {
        RMService.shared.execute(request, expecting: type) { [weak self] result in
            // Notify view of results, no results, or error
            switch result {
            case .success(let model):
                // episodes, characters: CollectionView, location: TableView
                self?.processSearchResults(model: model)
                
            case .failure:
                self?.handleNoResults()
                break
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var resultsVM: RMSearchResultViewModel?
        if let characterResults = model as? RMGetAllCharactersResponse {
            resultsVM = RMSearchResultViewModel.characters(characterResults.results.compactMap({
                return RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image)
                )
            }))
        }
        
        else if let episodesResults = model as? RMGetAllEpisodesResponse {
            resultsVM = RMSearchResultViewModel.episodes(episodesResults.results.compactMap({
                return RMCharacterEpisodeCollectionViewCellViewModel(episodeDataUrl: URL(string: $0.url))
            }))
        }
        else if let locationResults = model as? RMGetLocationsResponse {
            resultsVM = RMSearchResultViewModel.locations(locationResults.results.compactMap({
                return RMLocationTableViewCellViewModel(location: $0)
            }))
        }
        
        if let resultsVM = resultsVM {
            searchResultModel = model
            searchResultHandler?(resultsVM)
        } else {
            // callback error
            handleNoResults()
        }
    }
    
    public func locationSearchResult(at index: Int) -> RMLocation? {
        guard let searchModel = searchResultModel as? RMGetLocationsResponse else {
            return nil
        }
        
        return searchModel.results[index]
    }
    
    private func handleNoResults() {
        print("No Results")
        noResultHandler?()
    }
}
