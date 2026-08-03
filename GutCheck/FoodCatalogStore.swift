//
//  FoodCatalogStore.swift
//  GutCheck
//
//  Created by Andrew on 2026-08-03.
//

import SwiftUI
import Combine

/// A reusable food definition the user has saved — distinct from `FoodItem`,
/// which represents a single *logged* instance of a food on a given day.
/// `SavedFood` is the "master record" (name + default macros + tags) that
/// future logging can be built from, so the user doesn't retype macros
/// every time they eat the same thing.
struct SavedFood: Identifiable, Hashable {
    let id: UUID
    var name: String
    var protein: Int
    var carbs: Int
    var fats: Int
    var calories: Int
    var isFavorite: Bool = false
    var isAvoid: Bool = false
    var notes: String = ""
    var createdAt: Date = .now

    init(
        id: UUID = UUID(),
        name: String,
        protein: Int = 0,
        carbs: Int = 0,
        fats: Int = 0,
        calories: Int = 0,
        isFavorite: Bool = false,
        isAvoid: Bool = false,
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.calories = calories
        self.isFavorite = isFavorite
        self.isAvoid = isAvoid
        self.notes = notes
        self.createdAt = createdAt
    }

    /// Converts this saved definition into a loggable `FoodItem`, timestamped now.
    func asLoggedItem() -> FoodItem {
        FoodItem(name: name, protein: protein, carbs: carbs, fats: fats, calories: calories)
    }
}

/// In-memory catalog of foods the user has defined for themselves. This is
/// intentionally structured like a small repository (load/add/update/delete)
/// so swapping the in-memory dictionary for SwiftData/Core Data/a backend
/// database later only means changing this file — every view that reads
/// from `FoodCatalogStore` stays the same.
@MainActor
final class FoodCatalogStore: ObservableObject {
    @Published private(set) var foods: [SavedFood] = []

    init(seedSampleData: Bool = true) {
        if seedSampleData {
            seedSamples()
        }
    }

    // MARK: - Derived collections

    /// All foods, alphabetical.
    var sortedFoods: [SavedFood] {
        foods.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var favorites: [SavedFood] {
        sortedFoods.filter(\.isFavorite)
    }

    var avoids: [SavedFood] {
        sortedFoods.filter(\.isAvoid)
    }

    /// Foods tagged neither favorite nor avoid — everything else in the catalog.
    var untagged: [SavedFood] {
        sortedFoods.filter { !$0.isFavorite && !$0.isAvoid }
    }

    func matching(_ query: String) -> [SavedFood] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return sortedFoods }
        return sortedFoods.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }

    /// Case-insensitive exact lookup, useful for auto-filling macros when the
    /// user types a food name that's already in the catalog.
    func firstMatch(named name: String) -> SavedFood? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return foods.first { $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
    }

    // MARK: - Mutations

    func add(_ food: SavedFood) {
        foods.append(food)
    }

    func update(_ food: SavedFood) {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else { return }
        foods[index] = food
    }

    func delete(_ food: SavedFood) {
        foods.removeAll { $0.id == food.id }
    }

    func toggleFavorite(_ food: SavedFood) {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else { return }
        foods[index].isFavorite.toggle()
        if foods[index].isFavorite { foods[index].isAvoid = false }
    }

    func toggleAvoid(_ food: SavedFood) {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else { return }
        foods[index].isAvoid.toggle()
        if foods[index].isAvoid { foods[index].isFavorite = false }
    }

    private func seedSamples() {
        foods = [
            SavedFood(name: "Rice", protein: 4, carbs: 45, fats: 0, calories: 205, isFavorite: true),
            SavedFood(name: "Chicken", protein: 31, carbs: 0, fats: 4, calories: 165, isFavorite: true),
            SavedFood(name: "Dairy (Milk)", protein: 8, carbs: 12, fats: 8, calories: 150, isAvoid: true, notes: "Tends to cause bloating"),
            SavedFood(name: "Broccoli", protein: 3, carbs: 6, fats: 0, calories: 30, isAvoid: true, notes: "Gas")
        ]
    }
}
