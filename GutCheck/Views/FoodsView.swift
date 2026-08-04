//
//  FoodsView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct FoodsView: View {
    @EnvironmentObject private var catalog: FoodCatalogStore

    @State private var searchText = ""
    @State private var showingAddFood = false
    @State private var foodBeingEdited: SavedFood?

    private var filteredFavorites: [SavedFood] {
        searchText.isEmpty ? catalog.favorites : catalog.matching(searchText).filter(\.isFavorite)
    }
    private var filteredAvoids: [SavedFood] {
        searchText.isEmpty ? catalog.avoids : catalog.matching(searchText).filter(\.isAvoid)
    }
    private var filteredUntagged: [SavedFood] {
        searchText.isEmpty ? catalog.untagged : catalog.matching(searchText).filter { !$0.isFavorite && !$0.isAvoid }
    }

    var body: some View {
        NavigationStack {
            Group {
                if catalog.foods.isEmpty {
                    ContentUnavailableView(
                        "No Foods Yet",
                        systemImage: "fork.knife",
                        description: Text("Add foods you eat often to track how they make you feel.")
                    )
                } else {
                    List {
                        if !filteredFavorites.isEmpty {
                            Section("Favorites") {
                                ForEach(filteredFavorites) { food in
                                    FoodRow(food: food)
                                        .contentShape(Rectangle())
                                        .onTapGesture { foodBeingEdited = food }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                catalog.toggleFavorite(food)
                                            } label: {
                                                Label("Unfavorite", systemImage: "star.slash")
                                            }
                                            .tint(.yellow)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                catalog.delete(food)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                catalog.toggleAvoid(food)
                                            } label: {
                                                Label("Avoid", systemImage: "hand.raised")
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                        }

                        if !filteredAvoids.isEmpty {
                            Section("Avoid") {
                                ForEach(filteredAvoids) { food in
                                    FoodRow(food: food)
                                        .contentShape(Rectangle())
                                        .onTapGesture { foodBeingEdited = food }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                catalog.toggleAvoid(food)
                                            } label: {
                                                Label("Un-avoid", systemImage: "hand.raised.slash")
                                            }
                                            .tint(.orange)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                catalog.delete(food)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                catalog.toggleFavorite(food)
                                            } label: {
                                                Label("Favorite", systemImage: "star")
                                            }
                                            .tint(.yellow)
                                        }
                                }
                            }
                        }

                        if !filteredUntagged.isEmpty {
                            Section("All Foods") {
                                ForEach(filteredUntagged) { food in
                                    FoodRow(food: food)
                                        .contentShape(Rectangle())
                                        .onTapGesture { foodBeingEdited = food }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                catalog.toggleFavorite(food)
                                            } label: {
                                                Label("Favorite", systemImage: "star")
                                            }
                                            .tint(.yellow)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                catalog.delete(food)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                catalog.toggleAvoid(food)
                                            } label: {
                                                Label("Avoid", systemImage: "hand.raised")
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search foods")
                }
            }
            .navigationTitle("Foods")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add food")
                }
            }
            .sheet(isPresented: $showingAddFood) {
                NavigationStack {
                    AddFoodView { food in
                        catalog.add(food)
                    }
                }
            }
            .sheet(item: $foodBeingEdited) { food in
                NavigationStack {
                    AddFoodView(existing: food) { updated in
                        catalog.update(updated)
                    }
                }
            }
        }
    }
}

private struct FoodRow: View {
    let food: SavedFood

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.subheadline.weight(.medium))
                if food.calories > 0 || food.protein > 0 || food.carbs > 0 || food.fats > 0 {
                    Text("\(food.calories) kcal · P\(food.protein) C\(food.carbs) F\(food.fats)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !food.notes.isEmpty {
                    Text(food.notes)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if food.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            } else if food.isAvoid {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    FoodsView()
        .environmentObject(FoodCatalogStore(context: PersistenceSchema.previewContext()))
}

