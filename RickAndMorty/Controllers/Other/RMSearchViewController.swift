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
    
    private let config: Config
    
    // MARK: - Init
    init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = config.type.title
        view.backgroundColor = .systemBackground
    }
   
}
