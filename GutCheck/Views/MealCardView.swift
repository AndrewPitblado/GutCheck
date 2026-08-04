//
//  MealCardView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//
import SwiftUI

struct FoodItem: Identifiable, Hashable {
    var id: UUID
    var name: String
    var protein: Int
    var carbs: Int
    var fats: Int
    var calories: Int
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        protein: Int,
        carbs: Int,
        fats: Int,
        calories: Int,
        loggedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.calories = calories
        self.loggedAt = loggedAt
    }
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

    /// `allCases` grouped into rows of two, for simple two-column grids
    /// without needing `LazyVGrid`. Shared by Today and Log day detail.
    static var pairedRows: [[MealType]] {
        var rows: [[MealType]] = []
        var current: [MealType] = []
        for meal in allCases {
            current.append(meal)
            if current.count == 2 {
                rows.append(current)
                current.removeAll(keepingCapacity: true)
            }
        }
        if !current.isEmpty { rows.append(current) }
        return rows
    }
}


enum SymptomRating: Int, CaseIterable, Identifiable {
    case terrible = 1, bad, okay, good, great
    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .terrible: return "😣"
        case .bad: return "🙁"
        case .okay: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }

    var title: String {
        switch self {
        case .terrible: return "Terrible"
        case .bad: return "Bad"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    var color: Color {
        switch self {
        case .terrible: return .red
        case .bad: return .orange
        case .okay: return .yellow
        case .good: return .mint
        case .great: return .green
        }
    }
}

enum SymptomType: String, CaseIterable, Identifiable {
    case bloating, gas, abdominalPain, nausea, heartburn, fatigue, diarrhea, constipation
    var id: String { rawValue }

    var title: String {
        switch self {
        case .bloating: return "Bloating"
        case .gas: return "Gas"
        case .abdominalPain: return "Abdominal Pain"
        case .nausea: return "Nausea"
        case .heartburn: return "Heartburn"
        case .fatigue: return "Fatigue"
        case .diarrhea: return "Diarrhea"
        case .constipation: return "Constipation"
        }
    }
}

enum SymptomSeverity: Int, CaseIterable, Identifiable {
    case none = 0, mild, moderate, severe
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .none: return "None"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        }
    }
}

/// How a meal made the user feel: a quick overall rating plus optional,
/// specific symptom severities the user can fill in for more detail.
struct MealFeedback: Equatable {
    var overallRating: SymptomRating?
    var symptomSeverities: [SymptomType: SymptomSeverity] = [:]

    var hasSymptomDetails: Bool {
        symptomSeverities.values.contains { $0 != .none }
    }
}

struct MealCard: View {
    let meal: MealType
    let foods: [FoodItem]
    var feedback: MealFeedback? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meal.title)
                    .font(.headline)
                Spacer()
                if let rating = feedback?.overallRating {
                    Text(rating.emoji)
                        .font(.title3)
                } else {
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                }
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
        switch meal {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "fork.knife.circle.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
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
    @Binding var feedback: MealFeedback

    private func severityBinding(for symptom: SymptomType) -> Binding<SymptomSeverity> {
        Binding(
            get: { feedback.symptomSeverities[symptom, default: .none] },
            set: { feedback.symptomSeverities[symptom] = $0 }
        )
    }

    var body: some View {
        List {
            Section("How did you feel after this meal?") {
                HStack(spacing: 12) {
                    ForEach(SymptomRating.allCases) { option in
                        Button {
                            withAnimation {
                                feedback.overallRating = (feedback.overallRating == option) ? nil : option
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(option.emoji)
                                    .font(.title2)
                                Text(option.title)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(feedback.overallRating == option ? option.color.opacity(0.25) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(feedback.overallRating == option ? option.color : .clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            if feedback.overallRating != nil {
                Section {
                    ForEach(SymptomType.allCases) { symptom in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(symptom.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.subheadline)
                                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

                            Picker(symptom.title, selection: severityBinding(for: symptom)) {
                                ForEach(SymptomSeverity.allCases) { severity in
                                    Text(severity.title).tag(severity)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.segmented)
                            .alignmentGuide(.listRowSeparatorTrailing) { d in d.width }
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("Symptom Details (optional)")
                } footer: {
                    Text("Track specific symptoms to spot patterns with certain foods over time.")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

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

