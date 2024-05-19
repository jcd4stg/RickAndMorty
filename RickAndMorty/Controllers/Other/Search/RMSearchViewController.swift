//
//  RMSearchViewController.swift
//  RickAndMorty
//
//  Created by lynnguyen on 14/04/2024.
//

import UIKit

// Dynamic search option view
// Render Results
// Render no results zero state
// Searching / API Call

/// Configurable controller to search
class RMSearchViewController: UIViewController {
    /// Configuration for search session
    struct Config {
        enum `Type` {
            case character // name | status | gender
            case episode // allow name
            case location // name | type
            
            var endpoint: RMEndpoint {
                switch self {
                case .character:
                    return .character
                case .location:
                    return .location
                case .episode:
                    return .episode
                }
            }
            
            var title: String {
                switch self {
                case .character:
                    return "Search Character"
                case .episode:
                    return "Search Episode"
                case .location:
                    return "Search Location"
                }
            }
        }
        
        let type: `Type`
    }
    
    private let viewModel: RMSearchViewViewModel
    private let searchView: RMSearchView
    
    // MARK: - Init
    init(config: Config) {
        let viewModel = RMSearchViewViewModel(config: config)
        self.viewModel = viewModel
        self.searchView = RMSearchView(frame: .zero, viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.config.type.title
        view.backgroundColor = .systemBackground
        view.addSubview(searchView)
        searchView.delegate = self
        addConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapExecuteSearch))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.presentKeyboard()
    }
    
    @objc 
    private func didTapExecuteSearch() {
        viewModel.executeSearch()
    }
   
    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            searchView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        ])
    }
}

// MARK: - RMSearchViewDelegate
extension RMSearchViewController: RMSearchViewDelegate {
    
    func rmSearchView(_ searchView: RMSearchView, didSelectOption option: RMSearchInputViewViewModel.DynamicOption) {
        let vc = RMSearchOptionPickerViewController(option: option) { [weak self] selection in
            DispatchQueue.main.async {
                self?.viewModel.set(value: selection, for: option)
            }
        }
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
    }
    
    func rmSearchView(_ searchView: RMSearchView, didSelectLocation location: RMLocation) {
        let vc = RMLocationDetailViewController(location: location)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
