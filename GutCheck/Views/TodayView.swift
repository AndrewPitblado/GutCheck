//
//  TodayView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct TodayView: View {
    @State private var showingAddEntry = false

    // Simple in-memory placeholder foods per meal
    @State private var meals: [MealType: [String]] = [
        .breakfast: ["Oatmeal", "Banana"],
        .lunch: ["Chicken Salad"],
        .dinner: ["Rice", "Grilled Salmon"],
        .snack: ["Yogurt"]
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(MealType.allCases) { meal in
                            MealCard(meal: meal, foods: meals[meal] ?? [])
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 88) // leave space for floating button
                }

                // Bottom-centered floating add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddEntry = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text("Log")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundStyle(.white)
                            .shadow(radius: 4, y: 2)
                        }
                        .accessibilityLabel("Add or log entry")
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 80) // centers the capsule visually
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showingAddEntry) {
                NavigationStack { AddEntryView() }
            }
        }
    }
}


