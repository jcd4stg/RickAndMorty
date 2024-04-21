//
//  RMNoSearchResultsView.swift
//  RickAndMorty
//
//  Created by lynnguyen on 21/04/2024.
//

import UIKit

final class RMNoSearchResultsView: UIView {

    private let viewModel = RMNoSearchResultsViewViewModel()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        return iconView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        addSubviews(iconView, label)
        addConstraints()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 90),
            iconView.heightAnchor.constraint(equalToConstant: 90),
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),

        ])
    }
    
    private func configure() {
        label.text = viewModel.title
        iconView.image = viewModel.image
    }
}
