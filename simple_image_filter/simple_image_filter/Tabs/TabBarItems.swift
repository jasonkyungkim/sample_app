//
//  TabBarItems.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//

//import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case crop, dates
    
    var iconName: String {
        switch self {
        case .crop: return "photo.circle"
        case .dates: return "calendar.circle"
        }
    }
    
    var title: String {
        switch self {
        case .crop: return "Filter"
        case .dates: return "Dates"
       
        }
    }
    
    var color: Color {
        switch self {
        case .crop: return .bindigo.opacity(0.5)
        case .dates: return .bindigo.opacity(0.5)
        }
    }
}

