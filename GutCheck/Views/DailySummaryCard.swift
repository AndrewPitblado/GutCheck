//
//  DailySummaryCard.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-27.
//
import SwiftUI

struct DailySummaryCard: View {
    let meals: [MealType: [FoodItem]]
    var isExpanded: Bool = true

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
        Group {
            if isExpanded {
                expandedBody
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            } else {
                collapsedBody
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: isExpanded)
    }

    private var expandedBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Summary")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)

            HStack {
                macroColumn(title: "Calories", value: "\(totalCalories) kcal")
                Spacer()
                macroColumn(title: "Protein", value: "\(totalProtein) g")
                Spacer()
                macroColumn(title: "Carbs", value: "\(totalCarbs) g")
                Spacer()
                macroColumn(title: "Fats", value: "\(totalFats) g")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var collapsedBody: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.bar.doc.horizontal")
                .foregroundStyle(.secondary)

            Text("\(totalCalories) kcal")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()

            Text("·")
                .foregroundStyle(.tertiary)

            Text("P \(totalProtein)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Text("C \(totalCarbs)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Text("F \(totalFats)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Spacer(minLength: 0)

            Image(systemName: "chevron.up")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Daily summary, \(totalCalories) calories, protein \(totalProtein) grams, carbs \(totalCarbs) grams, fats \(totalFats) grams")
        .accessibilityHint("Expands full summary")
    }

    private func macroColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
            Text(value)
                .font(.title2)
                .bold()
                .monospacedDigit()
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: isExpanded ? 12 : 22, style: .continuous)
            .fill(Color(UIColor.secondarySystemBackground))
            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}
