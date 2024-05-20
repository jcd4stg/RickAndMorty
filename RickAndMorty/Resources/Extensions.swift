//
//  Extensions.swift
//  RickAndMorty
//
//  Created by lynnguyen on 04/04/2024.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}

extension UIDevice {
    static let isIphone = UIDevice.current.userInterfaceIdiom == .phone
}
