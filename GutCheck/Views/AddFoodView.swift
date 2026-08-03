//
//  AddFoodView.swift
//  GutCheck
//
//  Created by Andrew on 2026-08-03.
//

import SwiftUI

/// Sheet for creating or editing a `SavedFood` in the catalog.
/// Reused for both "Add Food" and tapping an existing food to edit it.
struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss

    let existing: SavedFood?
    let onSave: (SavedFood) -> Void

    @State private var name: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatsText: String
    @State private var caloriesText: String
    @State private var isFavorite: Bool
    @State private var isAvoid: Bool
    @State private var notes: String

    init(existing: SavedFood? = nil, onSave: @escaping (SavedFood) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _name = State(initialValue: existing?.name ?? "")
        _proteinText = State(initialValue: existing.map { "\($0.protein)" } ?? "")
        _carbsText = State(initialValue: existing.map { "\($0.carbs)" } ?? "")
        _fatsText = State(initialValue: existing.map { "\($0.fats)" } ?? "")
        _caloriesText = State(initialValue: existing.map { "\($0.calories)" } ?? "")
        _isFavorite = State(initialValue: existing?.isFavorite ?? false)
        _isAvoid = State(initialValue: existing?.isAvoid ?? false)
        _notes = State(initialValue: existing?.notes ?? "")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Form {
            Section("Food") {
                TextField("Name (e.g., Yogurt)", text: $name)
            }

            Section("Macros (optional)") {
                HStack {
                    Text("Protein (g)")
                    Spacer()
                    TextField("0", text: $proteinText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                HStack {
                    Text("Carbs (g)")
                    Spacer()
                    TextField("0", text: $carbsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                HStack {
                    Text("Fats (g)")
                    Spacer()
                    TextField("0", text: $fatsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                HStack {
                    Text("Calories")
                    Spacer()
                    TextField("0", text: $caloriesText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }

            Section("Tags") {
                Toggle("Favorite", isOn: $isFavorite)
                    .onChange(of: isFavorite) { _, newValue in
                        if newValue { isAvoid = false }
                    }
                Toggle("Avoid", isOn: $isAvoid)
                    .onChange(of: isAvoid) { _, newValue in
                        if newValue { isFavorite = false }
                    }
            }

            Section("Notes") {
                TextField("Why favorite/avoid? (optional)", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle(existing == nil ? "Add Food" : "Edit Food")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let food = SavedFood(
                        id: existing?.id ?? UUID(),
                        name: trimmedName,
                        protein: Int(proteinText) ?? 0,
                        carbs: Int(carbsText) ?? 0,
                        fats: Int(fatsText) ?? 0,
                        calories: Int(caloriesText) ?? 0,
                        isFavorite: isFavorite,
                        isAvoid: isAvoid,
                        notes: notes,
                        createdAt: existing?.createdAt ?? .now
                    )
                    onSave(food)
                    dismiss()
                }
                .disabled(trimmedName.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddFoodView { _ in }
    }
}
