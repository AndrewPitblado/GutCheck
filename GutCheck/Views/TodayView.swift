//
//  TodayView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: DayLogStore

    @State private var showingAddEntry = false
    @State private var selectedMealForDetail: MealType?

    /// Summary starts collapsed so it never competes with meal cards for space;
    /// the user taps to expand/collapse it deliberately.
    @State private var isSummaryExpanded = false

    private var dayLog: Binding<DayLog> {
        store.binding(for: Date())
    }

    private func feedbackBinding(for meal: MealType) -> Binding<MealFeedback> {
        Binding(
            get: { dayLog.wrappedValue.mealFeedback[meal, default: MealFeedback()] },
            set: { dayLog.wrappedValue.mealFeedback[meal] = $0 }
        )
    }

    private func foodsBinding(for meal: MealType) -> Binding<[FoodItem]> {
        Binding(
            get: { dayLog.wrappedValue.meals[meal, default: []] },
            set: { dayLog.wrappedValue.meals[meal] = $0 }
        )
    }

    private func addFoods(_ foods: [FoodItem], to meal: MealType) {
        dayLog.wrappedValue.meals[meal, default: []].append(contentsOf: foods)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                isSummaryExpanded.toggle()
                            }
                        } label: {
                            DailySummaryCard(meals: dayLog.wrappedValue.meals, isExpanded: isSummaryExpanded)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint(isSummaryExpanded ? "Collapses summary" : "Expands summary")

                        DayCheckInCard(checkIn: dayLog.checkIn)

                        ForEach(MealType.pairedRows.indices, id: \.self) { rowIndex in
                            HStack(spacing: 12) {
                                ForEach(MealType.pairedRows[rowIndex]) { meal in
                                    Button {
                                        selectedMealForDetail = meal
                                    } label: {
                                        MealCard(meal: meal, foods: dayLog.wrappedValue.meals[meal, default: []], feedback: dayLog.wrappedValue.mealFeedback[meal])
                                            .frame(maxWidth: .infinity)
                                            .aspectRatio(1.2, contentMode: .fit)
                                    }
                                    .buttonStyle(.plain)
                                }
                                if MealType.pairedRows[rowIndex].count == 1 {
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
                    .padding(.bottom, 100) // leave space for floating Log button
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .scrollDismissesKeyboard(.interactively)

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("Today")
                            .font(.headline)
                        Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                NavigationStack {
                    AddEntryView { meal, foods in
                        addFoods(foods, to: meal)
                    }
                }
            }
            .sheet(item: $selectedMealForDetail) { meal in
                NavigationStack {
                    MealDetailView(meal: meal, foods: foodsBinding(for: meal), feedback: feedbackBinding(for: meal))
                }
                .presentationDetents([.large])
            }
        }
    }
}
