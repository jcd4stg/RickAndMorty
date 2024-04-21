//
//  RMSettingsCellViewViewModel.swift
//  RickAndMorty
//
//  Created by lynnguyen on 16/04/2024.
//

import UIKit

struct RMSettingsCellViewModel: Identifiable {
    // Image | title
    let id = UUID()
    
    public let type: RMSettingsOption
    
    public let onTapHandle: ((RMSettingsOption) -> Void)
    
    // MARK: - Init
    init(type: RMSettingsOption, onTapHandle: @escaping (RMSettingsOption) -> Void) {
        self.type = type
        self.onTapHandle = onTapHandle
    }
    
    // MARK: - Public
    
    public var image: UIImage? {
        return type.iconImage
    }
    
    public var title: String {
        return type.displayTitle
    }
    
    public var iconContainerColor: UIColor {
        return type.iconContainerColor
    }
}
