//
//  ScrollHomeView.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//

import SwiftUI

struct ScrollHomeView: View {
    @State var scrollPosition: Int? = 0
    @State private var selectedDay: Int? = nil
    @State private var showDays = false
    let numberOfDays = 14
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Format the date as, e.g., "Sep 5"
        return formatter
    }()
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
        ZStack{
            DateScrollView(scrollPosition: $scrollPosition, selectedDay: $selectedDay)
            VStack{
                Button{
                    showDays.toggle()
                } label:{
                    VStack {
                        Text(isToday(date: days[scrollPosition ?? 0]) ? "Today" : formattedDate(date: days[scrollPosition ?? 0]))
                            .opacity(0.8)
                            .font(.title2)
                            .bold()
                            .transition(.opacity)
                        Text(" " + dayOfWeek(date: days[scrollPosition ?? 0]))
                            .font(.caption2)
                            .transition(.opacity)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThickMaterial)
                            .shadow(color: .primary.opacity(0.275), radius: 5, y: 2)
                    )
                    .bold()
                    .animation(.easeInOut, value: scrollPosition)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showDays, content: {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<days.count, id: \.self) { index in
                            Button(action: {
                                showDays = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    selectedDay = index
                                    scrollPosition = index
                                }
                            }) {
                                Text("\(dateFormatter.string(from: days[index]))")
                                    .padding()
                                    .foregroundStyle(.white)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.thinMaterial.opacity(0.8)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
                                    )
                                    .shadow(color: .indigo, radius: 5, y: 2.5) // Apply shadow conditionally
                                    .opacity(scrollPosition == index ? 1.0 : 0.25) // Optional subtle opacity difference
                            }
                            .id(index)
                            .padding(.horizontal, 5)
                            .padding(.vertical)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .onAppear {
                    if let index = scrollPosition {
                        proxy.scrollTo(index, anchor: .center)
                    }
                }
                .scrollIndicators(.never)
                .presentationDetents([.height(100)])
                .presentationBackground(.clear)
                .presentationCornerRadius(20)
            }
        })
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMdd")
        return formatter.string(from: date)
    }
    
    func dayOfWeek(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}
