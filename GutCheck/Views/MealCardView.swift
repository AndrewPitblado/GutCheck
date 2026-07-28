//
//  MealCardView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//
import SwiftUI

struct FoodItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var protein: Int
    var carbs: Int
    var fats: Int
    var calories: Int
    var loggedAt: Date = .now
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack
    var id: String { rawValue }
    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
    var backgroundColor: Color {
        switch self {
        case .breakfast: return .yellow.opacity(0.1)
        case .lunch: return .green.opacity(0.2)
        case .dinner: return .blue.opacity(0.3)
        case .snack: return .orange.opacity(0.2)
        }
    }
}


struct MealCard: View {
    let meal: MealType
    let foods: [FoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meal.title)
                    .font(.headline)
                Spacer()
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
            }
            if foods.isEmpty {
                Text("No items yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(foods.prefix(4)) { item in
                    HStack(spacing: 8) {
                        Text(emoji(for: item.name))
                        Text(item.name)
                            .lineLimit(1)
                    }
                }
                if foods.count > 4 {
                    Text("+ \(foods.count - 4) more…")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(meal.backgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    private var icon: String {
        switch meal.title {
        case "Breakfast": return "sunrise.fill"
        case "Lunch": return "fork.knife.circle.fill"
        case "Dinner": return "moon.stars.fill"
        default: return "leaf.fill"
        }
    }

    private func emoji(for food: String) -> String {
        let lower = food.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch lower {
        case _ where lower.contains("banana"): return "🍌"
        case _ where lower.contains("oat"): return "🥣"
        case _ where lower.contains("rice"): return "🍚"
        case _ where lower.contains("chicken"): return "🍗"
        case _ where lower.contains("salmon") || lower.contains("fish"): return "🐟"
        case _ where lower.contains("yogurt") || lower.contains("yoghurt"): return "🥛"
        case _ where lower.contains("salad"): return "🥗"
        case _ where lower.contains("apple"): return "🍎"
        case _ where lower.contains("bread") || lower.contains("toast"): return "🍞"
        case _ where lower.contains("egg"): return "🥚"
        default: return "🍽️"
        }
    }
}

struct MealDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let meal: MealType
    let foods: [FoodItem]

    var body: some View {
        List {
            if foods.isEmpty {
                ContentUnavailableView(
                    "No Foods Logged",
                    systemImage: "fork.knife",
                    description: Text("Add foods to this meal from the Today screen.")
                )
            } else {
                ForEach(foods) { food in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(food.name)
                                .font(.headline)
                            Spacer()
                            Text(food.loggedAt, format: .dateTime.hour().minute())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }

                        HStack(spacing: 16) {
                            MacroValue(title: "Calories", value: "\(food.calories) kcal")
                            MacroValue(title: "Protein", value: "\(food.protein) g")
                            MacroValue(title: "Carbs", value: "\(food.carbs) g")
                            MacroValue(title: "Fats", value: "\(food.fats) g")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(meal.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

private struct MacroValue: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }
}

