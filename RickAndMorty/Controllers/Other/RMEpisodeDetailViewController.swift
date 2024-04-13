//
//  RMEpisodeDetailViewController.swift
//  RickAndMorty
//
//  Created by lynnguyen on 13/04/2024.
//

import UIKit

// VC to show details about single episode
class RMEpisodeDetailViewController: UIViewController {

    private let url: URL?
    
    // MARK: - Init
    
    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episode"
        view.backgroundColor = .systemGreen
    }
    

   
}
