//
//  TrendsView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI
import Charts

// MARK: - Chart data models

private struct RatingCount: Identifiable {
    let rating: SymptomRating
    let count: Int
    var id: Int { rating.rawValue }
}

private struct RatingPoint: Identifiable {
    let date: Date
    let rating: SymptomRating
    var id: Date { date }
}

private struct FoodTally: Identifiable {
    let name: String
    let count: Int
    /// Symptoms most often logged on meals containing this food, most common first.
    let topSymptoms: [SymptomType]
    var id: String { name }
}

struct TrendsView: View {
    @EnvironmentObject private var store: DayLogStore

    private var days: [DayLog] {
        // Chronological order for trend lines.
        store.sortedDays.sorted { $0.date < $1.date }
    }

    // MARK: Day check-in tally

    private var dayRatingCounts: [RatingCount] {
        var counts: [SymptomRating: Int] = [:]
        for day in days {
            if let rating = day.checkIn.overallRating {
                counts[rating, default: 0] += 1
            }
        }
        return SymptomRating.allCases.map { RatingCount(rating: $0, count: counts[$0] ?? 0) }
    }

    private var totalDaysWithRating: Int {
        dayRatingCounts.reduce(0) { $0 + $1.count }
    }

    private var dayRatingTrend: [RatingPoint] {
        days.compactMap { day in
            guard let rating = day.checkIn.overallRating else { return nil }
            return RatingPoint(date: day.date, rating: rating)
        }
    }

    // MARK: Meal feedback tally

    private var mealRatingCounts: [RatingCount] {
        var counts: [SymptomRating: Int] = [:]
        for day in days {
            for feedback in day.mealFeedback.values {
                if let rating = feedback.overallRating {
                    counts[rating, default: 0] += 1
                }
            }
        }
        return SymptomRating.allCases.map { RatingCount(rating: $0, count: counts[$0] ?? 0) }
    }

    private var totalMealsWithRating: Int {
        mealRatingCounts.reduce(0) { $0 + $1.count }
    }

    // MARK: Food correlation

    /// Tallies food names by how the meal they were part of made the user feel.
    /// `good` = meals rated .good/.great, `bad` = meals rated .terrible/.bad.
    /// Also tracks which specific symptoms were logged alongside each food.
    private func foodTallies(good: Bool) -> [FoodTally] {
        var counts: [String: Int] = [:]
        var symptomCounts: [String: [SymptomType: Int]] = [:]
        for day in days {
            for (meal, foods) in day.meals {
                guard let feedback = day.mealFeedback[meal], let rating = feedback.overallRating else { continue }
                let matches = good ? (rating == .good || rating == .great)
                                   : (rating == .terrible || rating == .bad)
                guard matches else { continue }
                for food in foods {
                    counts[food.name, default: 0] += 1
                    for (symptom, severity) in feedback.symptomSeverities where severity != .none {
                        symptomCounts[food.name, default: [:]][symptom, default: 0] += 1
                    }
                }
            }
        }
        return counts
            .map { name, count in
                let symptoms = symptomCounts[name] ?? [:]
                let top = symptoms.sorted { $0.value > $1.value }.prefix(2).map { $0.key }
                return FoodTally(name: name, count: count, topSymptoms: Array(top))
            }
            .sorted { $0.count > $1.count }
            .prefix(6)
            .map { $0 }
    }

    private var goodFoods: [FoodTally] { foodTallies(good: true) }
    private var badFoods: [FoodTally] { foodTallies(good: false) }

    private var hasAnyData: Bool {
        !days.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if hasAnyData {
                    ScrollView {
                        VStack(spacing: 20) {
                            dayRatingSection
                            if dayRatingTrend.count > 1 {
                                trendSection
                            }
                            if totalMealsWithRating > 0 {
                                mealRatingSection
                            }
                            if !goodFoods.isEmpty || !badFoods.isEmpty {
                                foodCorrelationSection
                            }
                        }
                        .padding(20)
                    }
                } else {
                    ContentUnavailableView(
                        "No Trends Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Log a few days to see how your gut feels over time.")
                    )
                }
            }
            .navigationTitle("Trends")
        }
    }

    // MARK: Sections

    private var dayRatingSection: some View {
        TrendCard(title: "How Your Days Felt", subtitle: totalDaysWithRating > 0 ? "\(totalDaysWithRating) day\(totalDaysWithRating == 1 ? "" : "s") rated" : nil) {
            if totalDaysWithRating == 0 {
                emptyChartMessage("Rate your day from Today to see this chart.")
            } else {
                Chart(dayRatingCounts) { item in
                    BarMark(
                        x: .value("Rating", item.rating.title),
                        y: .value("Days", item.count)
                    )
                    .foregroundStyle(item.rating.color)
                    .cornerRadius(6)
                    .annotation(position: .top) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let title = value.as(String.self) {
                                Text(title)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 180)
            }
        }
    }

    private var trendSection: some View {
        TrendCard(title: "Rating Over Time", subtitle: "Day check-ins, most recent last") {
            Chart(dayRatingTrend) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Rating", point.rating.rawValue)
                )
                .foregroundStyle(.secondary)
                .symbol(.circle)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Rating", point.rating.rawValue)
                )
                .foregroundStyle(point.rating.color)
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                    AxisValueLabel {
                        if let raw = value.as(Int.self), let rating = SymptomRating(rawValue: raw) {
                            Text(rating.emoji)
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    AxisGridLine()
                }
            }
            .frame(height: 180)
        }
    }

    private var mealRatingSection: some View {
        TrendCard(title: "How Your Meals Felt", subtitle: "\(totalMealsWithRating) meal\(totalMealsWithRating == 1 ? "" : "s") rated") {
            Chart(mealRatingCounts) { item in
                BarMark(
                    x: .value("Rating", item.rating.title),
                    y: .value("Meals", item.count)
                )
                .foregroundStyle(item.rating.color)
                .cornerRadius(6)
                .annotation(position: .top) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let title = value.as(String.self) {
                            Text(title)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 180)
        }
    }

    private var foodCorrelationSection: some View {
        TrendCard(title: "Foods & How They Made You Feel", subtitle: nil) {
            VStack(alignment: .leading, spacing: 16) {
                if !goodFoods.isEmpty {
                    FoodTallyList(title: "Felt Good After", tint: SymptomRating.good.color, foods: goodFoods)
                }
                if !goodFoods.isEmpty && !badFoods.isEmpty {
                    Divider()
                }
                if !badFoods.isEmpty {
                    FoodTallyList(title: "Felt Bad After", tint: SymptomRating.bad.color, foods: badFoods)
                }
            }
        }
    }

    private func emptyChartMessage(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 100)
    }
}

// MARK: - Reusable card container

private struct TrendCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.quaternary, lineWidth: 1))
    }
}

private struct FoodTallyList: View {
    let title: String
    let tint: Color
    let foods: [FoodTally]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(foods) { food in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(food.name)
                            .font(.subheadline)
                        Spacer(minLength: 8)
                        Text("×\(food.count)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    if !food.topSymptoms.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(food.topSymptoms) { symptom in
                                Text(symptom.title)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(tint)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(tint.opacity(0.18)))
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 8).fill(tint.opacity(0.15)))
            }
        }
    }
}

#Preview {
    TrendsView()
        .environmentObject(DayLogStore(context: PersistenceSchema.previewContext()))
}
