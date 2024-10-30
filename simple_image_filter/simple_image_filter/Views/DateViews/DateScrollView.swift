//
//  DateScrollView.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//

import SwiftUI

struct DateScrollView: View {
    @State private var currentDate: Date = Date()

    let cols: Int = 3
    let spacing: CGFloat = 27.5
    let imgDiameter : CGFloat = UIScreen.main.bounds.width * 0.3
    var hexagonWidth: CGFloat { (imgDiameter / 2) * cos(.pi / 6) * 2 }
    
    @State private var showDateOptions = false
    
    @Binding var scrollPosition: Int?
    @Binding var selectedDay: Int?
    
    let numberOfDays = 14
    var days: [Date] {
        var dates = [Date]()
        let calendar = Calendar.current
        for i in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: i, to: Date()) {
                dates.append(date)
            }
        }
        return dates
    }
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.fixed(hexagonWidth), spacing: spacing), count: cols)
        GeometryReader{ geometry in
            ZStack {
                ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(0..<14, id: \.self) { date in
                                            ScrollView(.vertical) {
                                                LazyVGrid(columns: gridItems, spacing: spacing) {
                                                    Text("\(date)")
                                                }
                                                .padding(.top, geometry.size.height * 0.175)
                                                .padding(.bottom, 95)
                                                .frame(width: geometry.size.width)
                                            }
                                           
                                        .id(date) // Ensure unique ID for each day
                                        .scrollIndicators(.hidden)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0.6)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.5)
                                                .blur(radius: phase.isIdentity ? 0 : 5)
                                        }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollPosition(id: $scrollPosition)
                            .scrollTargetBehavior(.paging)
                            .onChange(of: selectedDay) { _,day in
                                // Scroll to the selected day when it changes
                                if let day = day {
                                    withAnimation {
                                        proxy.scrollTo(day, anchor: .center)
                                    }
                                }
                            }
                        }
                    .ignoresSafeArea()
            }
        }
    }

    
    func updateCurrentDate(with date: Date, in geometry: GeometryProxy) {
           let globalMinY = geometry.frame(in: .global).minY
           let screenHeight = UIScreen.main.bounds.height
           if globalMinY >= 0 && globalMinY < screenHeight / 2 {
               currentDate = date
           }
       }
    
    // Check if a date is today
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    // Format the date to show day and month
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMdd")
        return formatter.string(from: date)
    }
    
    // Get the day of the week
    func dayOfWeek(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}
