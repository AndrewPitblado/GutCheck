//
//  TodayView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct TodayView: View {
    @State private var showingAddEntry = false
    @State private var selectedMealForDetail: MealType?

    // Simple in-memory placeholder foods per meal
    @State private var meals: [MealType: [FoodItem]] = [
        .breakfast: [FoodItem(name: "Oatmeal", protein: 0, carbs: 0, fats: 0, calories: 0),
                     FoodItem(name: "Banana", protein: 0, carbs: 0, fats: 0, calories: 0)],
        .lunch: [FoodItem(name: "Chicken Salad", protein: 0, carbs: 0, fats: 0, calories: 0)],
        .dinner: [FoodItem(name: "Rice", protein: 0, carbs: 0, fats: 0, calories: 0),
                  FoodItem(name: "Grilled Salmon", protein: 0, carbs: 0, fats: 0, calories: 0)],
        .snack: [FoodItem(name: "Yogurt", protein: 0, carbs: 0, fats: 0, calories: 0)]
    ]

    // How the user felt after each meal, so they can spot patterns over time
    @State private var mealRatings: [MealType: SymptomRating] = [:]

    private func ratingBinding(for meal: MealType) -> Binding<SymptomRating?> {
        Binding(
            get: { mealRatings[meal] },
            set: { mealRatings[meal] = $0 }
        )
    }

    // Two-column rows of meals to avoid LazyVGrid
    private var mealRows: [[MealType]] {
        var rows: [[MealType]] = []
        var current: [MealType] = []
        for meal in MealType.allCases {
            current.append(meal)
            if current.count == 2 {
                rows.append(current)
                current.removeAll(keepingCapacity: true)
            }
        }
        if !current.isEmpty { rows.append(current) }
        return rows
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(mealRows.indices, id: \.self) { rowIndex in
                            HStack(spacing: 12) {
                                ForEach(mealRows[rowIndex]) { meal in
                                    Button {
                                        selectedMealForDetail = meal
                                    } label: {
                                        MealCard(meal: meal, foods: meals[meal, default: []], rating: mealRatings[meal])
                                            .frame(maxWidth: .infinity)
                                            .aspectRatio(1.2, contentMode: .fit)
                                    }
                                    .buttonStyle(.plain)
                                }
                                if mealRows[rowIndex].count == 1 {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1.2, contentMode: .fit)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 88) // leave space for floating button
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                
                //Card summarizing total calories, and macros for the day
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        DailySummaryCard(meals: meals)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120) // leave space for floating button
                        Spacer()
                    }
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
                            .shadow(radius: 4, x: 0, y: 2)
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
                NavigationStack {
                    AddEntryView { meal, foods in
                        meals[meal, default: []].append(contentsOf: foods)
                    }
                }
            }
            .sheet(item: $selectedMealForDetail) { meal in
                NavigationStack {
                    MealDetailView(meal: meal, foods: meals[meal, default: []], rating: ratingBinding(for: meal))
                }
                .presentationDetents([.large])
            }
        }
    }
}

