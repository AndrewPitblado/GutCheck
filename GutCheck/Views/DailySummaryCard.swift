//
//  DailySummaryCard.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-27.
//
import SwiftUI

struct DailySummaryCard: View {
    let meals: [MealType: [FoodItem]]

    private var foods: [FoodItem] {
        meals.values.flatMap { $0 }
    }

    private var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }

    private var totalProtein: Int {
        foods.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Int {
        foods.reduce(0) { $0 + $1.carbs }
    }

    private var totalFats: Int {
        foods.reduce(0) { $0 + $1.fats }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Summary")
                .font(.headline)
                .padding(.bottom, 4)

            HStack {
                VStack(alignment: .leading) {
                    Text("Calories")
                        .font(.subheadline)
                    Text("\(totalCalories) kcal")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Protein")
                        .font(.subheadline)
                    Text("\(totalProtein) g")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Carbs")
                        .font(.subheadline)
                    Text("\(totalCarbs) g")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Fats")
                        .font(.subheadline)
                    Text("\(totalFats) g")
                        .font(.title2)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }

}
