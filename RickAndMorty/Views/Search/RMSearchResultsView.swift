//
//  RMSearchResultsView.swift
//  RickAndMorty
//
//  Created by lynnguyen on 28/04/2024.
//

import UIKit

protocol RMSearchResultsViewDelegate: AnyObject {
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didTapLocationAt index: Int)
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didTapCharacterAt index: Int)
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didTapEpisodeAt index: Int)

}

/// show search results UI (table or collection as needed)
final class RMSearchResultsView: UIView {

    weak var delegate: RMSearchResultsViewDelegate?
    
    private var viewModel: RMSearchResultViewModel? {
        didSet {
            self.processViewModel()
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RMLocationTableViewCell.self, 
                           forCellReuseIdentifier: RMLocationTableViewCell.identifier)
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(RMCharacterCollectionViewCell.self,
                                forCellWithReuseIdentifier: RMCharacterCollectionViewCell.identifier)
        
        collectionView.register(RMCharacterEpisodeCollectionViewCell.self,
                                forCellWithReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier)
        
        collectionView.register(RMFooterLoadingCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier)
        
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = true
        return collectionView
    }()
    
    // TableView viewModels
    private var locationCellViewModel: [RMLocationTableViewCellViewModel] = []
    
    // CollectionView viewModels
    private var collectionViewCellViewModels: [any Hashable] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tableView, collectionView)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
   
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

        ])
          
    }
    
    private func processViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        switch viewModel.results {
        case .characters(let viewModels):
            collectionViewCellViewModels = viewModels
            setupCollectionView()
        case .locations(let viewModels):
            setupTableView(viewModels: viewModels)
        case .episodes(let viewModels):
            collectionViewCellViewModels = viewModels
            setupCollectionView()
        
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.isHidden = true
        collectionView.isHidden = false

        collectionView.reloadData()
    }
    
    private func setupTableView(viewModels: [RMLocationTableViewCellViewModel]) {
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.isHidden = true
        tableView.isHidden = false
        locationCellViewModel = viewModels
        tableView.reloadData()

    }
    
    public func configure(with viewModel: RMSearchResultViewModel) {
        self.viewModel = viewModel
    }
    
}


// MARK: - TableView
extension RMSearchResultsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationCellViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RMLocationTableViewCell.identifier,
            for: indexPath
        ) as? RMLocationTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: locationCellViewModel[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.rmSearchResultsView(self, didTapLocationAt: indexPath.row)
    }
}

// MARK: - CollectionView
extension RMSearchResultsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Character | Episode
        let currentViewModel = collectionViewCellViewModels[indexPath.row]
        
        if let characterVM = currentViewModel as? RMCharacterCollectionViewCellViewModel {
            // Character cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RMCharacterCollectionViewCell.identifier,
                for: indexPath
            ) as? RMCharacterCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: characterVM)
            return cell
        }
        
        // episode
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier,
            for: indexPath
        ) as? RMCharacterEpisodeCollectionViewCell else {
            fatalError()
        }
        
        if let episodeVM = currentViewModel as? RMCharacterEpisodeCollectionViewCellViewModel {
            cell.configure(with: episodeVM)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // TODO: handle cell tap
        guard let viewModel = viewModel else {
            return
        }
        
        switch viewModel.results {
        case .characters:
            delegate?.rmSearchResultsView(self, didTapCharacterAt: indexPath.row)
        case .episodes:
            delegate?.rmSearchResultsView(self, didTapEpisodeAt: indexPath.row)
        case .locations:
            break
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentViewModel = collectionViewCellViewModels[indexPath.row]
        let bounds = collectionView.bounds

        if currentViewModel is RMCharacterCollectionViewCellViewModel {
            // character Size
            let width = UIDevice.isIphone ? ((bounds.width - 30) / 2) : ((bounds.width - 50) / 4)
            return CGSize(width: width, height: width * 1.5)
        }
        // Episode size
        let width = UIDevice.isIphone ? bounds.width - 20 : ((bounds.width - 50) / 4)
        
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
                for: indexPath
              ) as? RMFooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        if let viewModel = viewModel, viewModel.shouldShowLoadMoreIndicator {
            footerView.startAnimating()
        }
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard let viewModel = viewModel,
              viewModel.shouldShowLoadMoreIndicator else {
            return .zero
        }
        return CGSize(width: collectionView.frame.width,
                      height: 100)
    }
}

// MARK: - ScrollViewDelegate
extension RMSearchResultsView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !locationCellViewModel.isEmpty {
            handleLocationPagination(scrollView: scrollView)
        } else {
            // CollectionView
            handleCharacterOrEpisodePagination(scrollView: scrollView)
        }
    }
    
    private func handleCharacterOrEpisodePagination(scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !collectionViewCellViewModels.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreResults else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            let offset = scrollView.contentOffset.y
            let totalContentlHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentlHeight - totalScrollViewFixedHeight - 120) {
                
                viewModel.fetchAdditionalResults { [weak self] newResults in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.tableFooterView = nil
                        
                        let originalCount = strongSelf.collectionViewCellViewModels.count
                        let newCount = newResults.count - originalCount
                        let total = originalCount + newCount
                        let startingIndex = total - newCount
                        let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount)).compactMap {
                            return IndexPath(row: $0, section: 0)
                        }
                        
                        strongSelf.collectionViewCellViewModels = newResults
                        strongSelf.collectionView.insertItems(at: indexPathsToAdd)
                    }
                }
            }
            timer.invalidate()
        }
    }

    private func handleLocationPagination(scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !locationCellViewModel.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreResults else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            let offset = scrollView.contentOffset.y
            let totalContentlHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            
            if offset >= (totalContentlHeight - totalScrollViewFixedHeight - 120) {
                DispatchQueue.main.async {
                    self?.showTableLoadingIndicator()
                }
                viewModel.fetchAdditionalLocations { [weak self] newResults in
                    // Refresh table
                    self?.tableView.tableFooterView = nil
                    self?.locationCellViewModel = newResults
                    self?.tableView.reloadData()
                }
                
            }
            timer.invalidate()
        }
    }
    
    private func showTableLoadingIndicator() {
        let footer = RMTableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        tableView.tableFooterView = footer
    }
}

