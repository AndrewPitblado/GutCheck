//
//  PersistenceModels.swift
//  GutCheck
//
//  SwiftData-backed persistence. `DayLogStore` and `FoodCatalogStore` still
//  expose plain-struct APIs (`DayLog`, `FoodItem`, `SavedFood`, ...) so views
//  don't need to know persistence exists — these `@Model` classes and the
//  conversion helpers below are the only things that changed under the hood.
//

import Foundation
import SwiftData

// MARK: - Persisted models

/// One calendar day's worth of logging. Foods are a to-many relationship
/// (`FoodEntryModel`); meal feedback and the day check-in are stored as
/// small Codable payloads directly on the day, since SwiftData supports
/// Codable attributes natively and this avoids a relationship per meal.
@Model
final class DayLogModel {
    @Attribute(.unique) var date: Date
    var checkInRatingRaw: Int?
    var checkInNotes: String
    var mealFeedbackData: [String: MealFeedbackData]

    @Relationship(deleteRule: .cascade, inverse: \FoodEntryModel.day)
    var foodEntries: [FoodEntryModel] = []

    init(
        date: Date,
        checkInRatingRaw: Int? = nil,
        checkInNotes: String = "",
        mealFeedbackData: [String: MealFeedbackData] = [:]
    ) {
        self.date = date
        self.checkInRatingRaw = checkInRatingRaw
        self.checkInNotes = checkInNotes
        self.mealFeedbackData = mealFeedbackData
    }
}

/// A single logged food, tied to the day and meal it was logged under.
@Model
final class FoodEntryModel {
    var id: UUID
    var name: String
    var protein: Int
    var carbs: Int
    var fats: Int
    var calories: Int
    var quantity: Int = 1
    var loggedAt: Date
    var mealTypeRaw: String
    var day: DayLogModel?

    init(
        id: UUID = UUID(),
        name: String,
        protein: Int,
        carbs: Int,
        fats: Int,
        calories: Int,
        quantity: Int = 1,
        loggedAt: Date,
        mealTypeRaw: String
    ) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.calories = calories
        self.quantity = quantity
        self.loggedAt = loggedAt
        self.mealTypeRaw = mealTypeRaw
    }
}

/// The user's reusable food catalog (Foods tab).
@Model
final class SavedFoodModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var protein: Int
    var carbs: Int
    var fats: Int
    var calories: Int
    var quantity: Int = 1
    var isFavorite: Bool
    var isAvoid: Bool
    var notes: String
    var createdAt: Date

    init(
        id: UUID,
        name: String,
        protein: Int,
        carbs: Int,
        fats: Int,
        calories: Int,
        quantity: Int,
        isFavorite: Bool,
        isAvoid: Bool,
        notes: String,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.calories = calories
        self.quantity = quantity
        self.isFavorite = isFavorite
        self.isAvoid = isAvoid
        self.notes = notes
        self.createdAt = createdAt
    }
}

/// Codable payload for `MealFeedback`, stored directly as a `DayLogModel`
/// attribute (keyed by `MealType.rawValue`) instead of its own relationship.
struct MealFeedbackData: Codable {
    var overallRatingRaw: Int?
    var symptomSeverities: [String: Int]

    init(feedback: MealFeedback) {
        overallRatingRaw = feedback.overallRating?.rawValue
        symptomSeverities = Dictionary(
            uniqueKeysWithValues: feedback.symptomSeverities.map { ($0.key.rawValue, $0.value.rawValue) }
        )
    }

    var asMealFeedback: MealFeedback {
        MealFeedback(
            overallRating: overallRatingRaw.flatMap(SymptomRating.init(rawValue:)),
            symptomSeverities: Dictionary(
                uniqueKeysWithValues: symptomSeverities.compactMap { key, value -> (SymptomType, SymptomSeverity)? in
                    guard let symptom = SymptomType(rawValue: key), let severity = SymptomSeverity(rawValue: value) else {
                        return nil
                    }
                    return (symptom, severity)
                }
            )
        )
    }
}

// MARK: - DayLog <-> DayLogModel conversion

extension DayLog {
    init(model: DayLogModel) {
        self.date = model.date

        var meals: [MealType: [FoodItem]] = [:]
        for entry in model.foodEntries {
            guard let mealType = MealType(rawValue: entry.mealTypeRaw) else { continue }
            meals[mealType, default: []].append(
                FoodItem(
                    id: entry.id,
                    name: entry.name,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fats: entry.fats,
                    calories: entry.calories,
                    quantity: max(1, entry.quantity),
                    loggedAt: entry.loggedAt
                )
            )
        }
        for key in meals.keys {
            meals[key]?.sort { $0.loggedAt < $1.loggedAt }
        }
        self.meals = meals

        var feedback: [MealType: MealFeedback] = [:]
        for (rawMeal, data) in model.mealFeedbackData {
            guard let mealType = MealType(rawValue: rawMeal) else { continue }
            feedback[mealType] = data.asMealFeedback
        }
        self.mealFeedback = feedback

        self.checkIn = DayCheckIn(
            overallRating: model.checkInRatingRaw.flatMap(SymptomRating.init(rawValue:)),
            notes: model.checkInNotes
        )
    }

    /// Writes this struct's current state into the given persisted model,
    /// replacing its food entries wholesale (simple and correct at the
    /// data volumes a single day's log involves).
    func apply(to model: DayLogModel, context: ModelContext) {
        model.checkInRatingRaw = checkIn.overallRating?.rawValue
        model.checkInNotes = checkIn.notes
        model.mealFeedbackData = Dictionary(
            uniqueKeysWithValues: mealFeedback.map { ($0.key.rawValue, MealFeedbackData(feedback: $0.value)) }
        )

        for entry in model.foodEntries {
            context.delete(entry)
        }
        model.foodEntries.removeAll()

        for (mealType, foods) in meals {
            for food in foods {
                let entry = FoodEntryModel(
                    id: food.id,
                    name: food.name,
                    protein: food.protein,
                    carbs: food.carbs,
                    fats: food.fats,
                    calories: food.calories,
                    quantity: food.quantity,
                    loggedAt: food.loggedAt,
                    mealTypeRaw: mealType.rawValue
                )
                entry.day = model
                model.foodEntries.append(entry)
                context.insert(entry)
            }
        }
    }
}

// MARK: - SavedFood <-> SavedFoodModel conversion

extension SavedFood {
    init(model: SavedFoodModel) {
        self.init(
            id: model.id,
            name: model.name,
            protein: model.protein,
            carbs: model.carbs,
            fats: model.fats,
            calories: model.calories,
            quantity: max(1, model.quantity),
            isFavorite: model.isFavorite,
            isAvoid: model.isAvoid,
            notes: model.notes,
            createdAt: model.createdAt
        )
    }

    func apply(to model: SavedFoodModel) {
        model.name = name
        model.protein = protein
        model.carbs = carbs
        model.fats = fats
        model.calories = calories
        model.quantity = quantity
        model.isFavorite = isFavorite
        model.isAvoid = isAvoid
        model.notes = notes
        model.createdAt = createdAt
    }
}

/// Shared app schema, used both by the real app and by SwiftUI previews
/// (with an in-memory configuration) so both stay in sync.
enum PersistenceSchema {
    static var models: [any PersistentModel.Type] {
        [DayLogModel.self, FoodEntryModel.self, SavedFoodModel.self]
    }

    /// An in-memory container for `#Preview`s, so previews never touch the
    /// real on-disk store and always start from a clean slate.
    @MainActor
    static func previewContext() -> ModelContext {
        let schema = Schema(models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }
}
