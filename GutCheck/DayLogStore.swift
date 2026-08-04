//
//  DayLogStore.swift
//  GutCheck
//
//  Created by Andrew on 2026-08-01.
//

import SwiftUI
import SwiftData
import Combine

/// Everything logged for a single calendar day: foods per meal, how each
/// meal made the user feel, and an overall day-level check-in.
struct DayLog: Identifiable {
    var date: Date // always normalized to start-of-day
    var meals: [MealType: [FoodItem]] = [:]
    var mealFeedback: [MealType: MealFeedback] = [:]
    var checkIn: DayCheckIn = DayCheckIn()

    var id: Date { date }

    var allFoods: [FoodItem] {
        meals.values.flatMap { $0 }
    }

    var totalCalories: Int {
        allFoods.reduce(0) { $0 + $1.calories }
    }

    var loggedMeals: [MealType] {
        MealType.allCases.filter { !(meals[$0]?.isEmpty ?? true) }
    }

    /// True if nothing at all has been logged for this day yet.
    var isEmpty: Bool {
        loggedMeals.isEmpty && checkIn.isEmpty
    }
}

/// Store of every day's log, backed by SwiftData so entries survive app
/// restarts. Today, Log, and Trends all read/write through this same
/// instance. Views never touch `ModelContext` or the `@Model` types
/// directly — they only ever see plain `DayLog`/`FoodItem` structs.
@MainActor
final class DayLogStore: ObservableObject {
    private let context: ModelContext
    @Published private var daysByDate: [Date: DayLog] = [:]

    /// - Parameter seedSampleDataIfEmpty: only seeds demo data the very
    ///   first time the store is empty (e.g. a fresh install), so it never
    ///   re-appears once the user has real data of their own.
    init(context: ModelContext, seedSampleDataIfEmpty: Bool = true) {
        self.context = context
        reloadFromDisk()
        if seedSampleDataIfEmpty && daysByDate.isEmpty {
            seedSamples()
        }
    }

    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func reloadFromDisk() {
        let descriptor = FetchDescriptor<DayLogModel>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        guard let models = try? context.fetch(descriptor) else { return }
        var result: [Date: DayLog] = [:]
        for model in models {
            result[model.date] = DayLog(model: model)
        }
        daysByDate = result
    }

    func dayLog(for date: Date) -> DayLog {
        let key = Self.startOfDay(date)
        return daysByDate[key] ?? DayLog(date: key)
    }

    /// Two-way binding to a given day's log, creating and persisting an
    /// empty one on first write.
    func binding(for date: Date) -> Binding<DayLog> {
        let key = Self.startOfDay(date)
        return Binding(
            get: { self.daysByDate[key] ?? DayLog(date: key) },
            set: { self.persist($0) }
        )
    }

    /// Every day that has at least some data, most recent first.
    var sortedDays: [DayLog] {
        daysByDate.values
            .filter { !$0.isEmpty }
            .sorted { $0.date > $1.date }
    }

    private func persist(_ dayLog: DayLog) {
        let key = dayLog.date
        daysByDate[key] = dayLog

        let descriptor = FetchDescriptor<DayLogModel>(predicate: #Predicate { $0.date == key })
        let model: DayLogModel
        if let existing = try? context.fetch(descriptor).first {
            model = existing
        } else {
            model = DayLogModel(date: key)
            context.insert(model)
        }
        dayLog.apply(to: model, context: context)
        try? context.save()
    }

    private func seedSamples() {
        let calendar = Calendar.current

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            var log = DayLog(date: Self.startOfDay(yesterday))
            log.meals[.lunch] = [
                FoodItem(name: "Sushi", protein: 24, carbs: 52, fats: 9, calories: 410)
            ]
            log.mealFeedback[.lunch] = MealFeedback(
                overallRating: .okay,
                symptomSeverities: [.fatigue: .mild]
            )
            log.meals[.dinner] = [
                FoodItem(name: "Pasta", protein: 14, carbs: 68, fats: 16, calories: 520)
            ]
            log.mealFeedback[.dinner] = MealFeedback(
                overallRating: .bad,
                symptomSeverities: [.bloating: .moderate, .gas: .mild]
            )
            log.checkIn = DayCheckIn(overallRating: .bad, notes: "Stressful day at work, slept poorly.")
            persist(log)
        }

        if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date()) {
            var log = DayLog(date: Self.startOfDay(twoDaysAgo))
            log.meals[.breakfast] = [
                FoodItem(name: "Oatmeal", protein: 6, carbs: 40, fats: 5, calories: 260),
                FoodItem(name: "Banana", protein: 1, carbs: 27, fats: 0, calories: 105)
            ]
            log.mealFeedback[.breakfast] = MealFeedback(overallRating: .great)
            log.checkIn = DayCheckIn(overallRating: .good)
            persist(log)
        }
    }
}
