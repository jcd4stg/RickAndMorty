//
//  RMLocationViewViewModel.swift
//  RickAndMorty
//
//  Created by lynnguyen on 19/04/2024.
//

import Foundation

protocol RMLocationViewViewModelDelegate: AnyObject {
    func didFetchInitialLocation()
}

final class RMLocationViewViewModel {
    
    weak var delegate: RMLocationViewViewModelDelegate?
    
    private var locations: [RMLocation] = [] {
        didSet {
            for location in locations {
                let cellViewModel = RMLocationTableViewCellViewModel(location: location)
                if !cellViewModels.contains(cellViewModel) {
                    cellViewModels.append(cellViewModel)
                }
            }
        }
    }
    
    // Location response
    // will contain next url, if present
    private var apiInfo: RMGetLocationsResponse.Info?
    
    public private(set) var cellViewModels: [RMLocationTableViewCellViewModel] = []
    
    public var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
    
    public var isLoadingMoreLocations = false

    private var didFinishPagination: (() -> Void)?
    
    // MARK: Init
    init() {}
    
    public func registerDidFinishPaginationBlock(_ block: @escaping () -> Void) {
        didFinishPagination = block
    }
    
    /// Paginate if additional locations are neede
    public func fetchAdditionalLocations() {
        // Fetch characters
        guard !isLoadingMoreLocations else {
            return
        }
        
        guard let nextUrlString = apiInfo?.next,
              let url = URL(string: nextUrlString) else {
            return
        }
        
        isLoadingMoreLocations = true
    
        guard let request = RMRequest(url: url) else {
            isLoadingMoreLocations = false
            return
        }
        
        RMService.shared.execute(
            request,
            expecting: RMGetLocationsResponse.self
        ) { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let responseModel):
                
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                strongSelf.cellViewModels.append(contentsOf: moreResults.compactMap({
                    return RMLocationTableViewCellViewModel(location: $0)
                }))
                
                DispatchQueue.main.async {
                    strongSelf.isLoadingMoreLocations = false
                    
                    // Notify via callback
                    strongSelf.didFinishPagination?()
                }
            case .failure(let failure):
                print(String(describing: failure))
                strongSelf.isLoadingMoreLocations = false
            }
        }
    }
    
    public func location(at index: Int) -> RMLocation? {
        guard index < locations.count, index >= 0 else {
            return nil
        }
        
        return locations[index]
    }
    
    public func fetchLocations() {
        
        RMService.shared.execute(.listLocationRequests, expecting: RMGetLocationsResponse.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.apiInfo = model.info
                self?.locations = model.results
                DispatchQueue.main.async {
                    self?.delegate?.didFetchInitialLocation()
                }
            case .failure(let failure):
                // TODO: Handle error
                break
            }
        }
    }
    
    private var hasMoreResults: Bool {
        return false
    }
}
