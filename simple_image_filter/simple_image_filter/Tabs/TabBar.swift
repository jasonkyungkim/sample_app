//
//  TabBar.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//


import SwiftUI

struct TabBar: View {
    let tabs: [TabBarItem]
    let contentShape = RoundedRectangle(cornerRadius: 30.0)
    @State private var showMenu = true
    @Binding var selection: TabBarItem
    
    // For matchedGeometryEffect
    @State var localSelection: TabBarItem
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            Spacer()
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        tabView(tab: tab)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
                .background {
                    contentShape
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(height:65)
                }
                
                .onChange(of: selection) { _, newValue in
                    withAnimation(.snappy(duration: 0.125)) {
                        localSelection = newValue
                    }
                }
                .offset(y: showMenu ? 0 : 150)
                .animation(.snappy,value: showMenu)
            
            Button {
                withAnimation(.spring) {
                    showMenu.toggle()
                }
            } label: {
                Image(systemName: "chevron.up")
                    .bold()
                    .rotationEffect(Angle(degrees: showMenu ? 180 : 0))
                    .animation(.spring, value: showMenu)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(RoundedRectangle(cornerRadius: 25).fill( showMenu ? .ultraThickMaterial : .ultraThinMaterial).shadow(color:.primary.opacity(0.25), radius: showMenu ? 10 : 0))
            }
            .padding(.bottom)
        }
    }
}

extension TabBar {
    private func tabView(tab: TabBarItem) -> some View {
        HStack {
            if tab == selection {
                Image(systemName:  "\(tab.iconName)" != "eyes" ? "\(tab.iconName).fill" : "\(tab.iconName).inverse")
                    .font(.title2).bold()
                    .symbolEffect(.bounce, value: localSelection)
                    .foregroundStyle(.primary)
//                    .shadow(color: tab.color, radius: 10)
                    .frame(height: 15)
            } else {
                Image(systemName: tab.iconName)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(height: 35)
            }
            
            Text(tab.title)
                .font(.title3)
                .bold()
                .foregroundStyle(localSelection == tab ? .primary : .secondary)
        }
//        .ignoresSafeArea()
//        .frame(maxWidth: .infinity)
        .padding()
        .background(
            ZStack {
                if localSelection == tab {
                    contentShape
                        .fill(.ultraThickMaterial)
                        .presentationCornerRadius(25)
                        .shadow(color:.primary.opacity(0.25), radius: 2.5, y:2.5)
                        .frame(height:45)
                        .matchedGeometryEffect(id: "tabHighlighting", in: namespace)
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showMenu = false
                            }
                        }
                }
            }
        )
        .accessibilityElement(children: .combine)
        .contentShape(contentShape)
        .onTapGesture {
            switchToTab(tab)
        }
    }
    
    private func switchToTab(_ newTab: TabBarItem) {
        selection = newTab
    }
}


