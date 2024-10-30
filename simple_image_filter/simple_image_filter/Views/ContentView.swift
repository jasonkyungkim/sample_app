//
//  ContentView.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//
import SwiftUI

struct ContentView: View {
    @State private var tabSelection: TabBarItem = .crop
    var body: some View {
        TabBarContainer(selection: $tabSelection) {
            CropImageView()
                .tabBarItem(tab: .crop, selection: $tabSelection)
            ScrollHomeView()
                .tabBarItem(tab: .dates, selection: $tabSelection)
        }
    }
}
