//
//  DayDetailView.swift
//  GutCheck
//
//  Created by Andrew on 2026-08-01.
//

import SwiftUI

/// Read/edit view for a single past (or today's) day, reached from the Log tab.
/// Reuses the same cards as Today so logging retroactively feels identical.
struct DayDetailView: View {
    let date: Date

    @EnvironmentObject private var store: DayLogStore
    @State private var selectedMealForDetail: MealType?
    @State private var showingAddEntry = false

    private var dayLog: Binding<DayLog> {
        store.binding(for: date)
    }

    private func feedbackBinding(for meal: MealType) -> Binding<MealFeedback> {
        Binding(
            get: { dayLog.wrappedValue.mealFeedback[meal, default: MealFeedback()] },
            set: { dayLog.wrappedValue.mealFeedback[meal] = $0 }
        )
    }

    private func addFoods(_ foods: [FoodItem], to meal: MealType) {
        dayLog.wrappedValue.meals[meal, default: []].append(contentsOf: foods)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                DailySummaryCard(meals: dayLog.wrappedValue.meals)

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
            .padding(20)
        }
        .navigationTitle(Text(date, format: .dateTime.weekday(.wide).month().day()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add or log entry for this day")
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
                MealDetailView(meal: meal, foods: dayLog.wrappedValue.meals[meal, default: []], feedback: feedbackBinding(for: meal))
            }
            .presentationDetents([.large])
        }
    }
}

private struct DayDetailPreviewHost: View {
    let context = PersistenceSchema.previewContext()

    var body: some View {
        NavigationStack {
            DayDetailView(date: Date())
        }
        .environmentObject(DayLogStore(context: context))
        .environmentObject(FoodCatalogStore(context: context))
    }
}

#Preview {
    DayDetailPreviewHost()
}
