//
//  TabBarContainer.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//
import SwiftUI

struct TabBarContainer<Content: View>: View {
    let content: Content
    @Binding var selection: TabBarItem
    @State private var tabs: [TabBarItem] = []
    
    init(selection: Binding<TabBarItem>,
         @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content

            TabBar(tabs: tabs,
                           selection: $selection,
                           localSelection: selection)
            .padding()
            .ignoresSafeArea()
        }
        .onPreferenceChange(TabBarItemPreferenceKey.self, perform: { value in
            self.tabs = value
        })
    }
}


