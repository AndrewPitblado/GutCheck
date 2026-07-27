//
//  MealCardView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//
import SwiftUI



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
    let foods: [String]

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
                ForEach(foods.prefix(4), id: \.self) { item in
                    Text("• \(item)")
                        .lineLimit(1)
                }
                if foods.count > 4 {
                    Text("+ \(foods.count - 4) more…")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(meal.backgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    private var icon: String {
        switch meal.title {
        case "Breakfast": return "sunrise.fill"
        case "Lunch": return "fork.knife.circle.fill"
        case "Dinner": return "moon.stars.fill"
        default: return "leaf.fill"
        }
    }
}
