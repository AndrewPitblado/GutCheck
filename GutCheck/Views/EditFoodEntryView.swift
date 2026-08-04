//
//  EditFoodEntryView.swift
//  GutCheck
//
//  Sheet for editing an already-logged food entry from within a meal's
//  detail view. Mirrors `AddEntryView`'s per-unit × quantity math: macros
//  are shown per unit (derived from the entry's stored totals) and
//  recombined with the (possibly edited) quantity on save.
//

import SwiftUI

struct EditFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss

    let original: FoodItem
    let onSave: (FoodItem) -> Void

    @State private var name: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatsText: String
    @State private var caloriesText: String
    @State private var quantity: Int

    init(food: FoodItem, onSave: @escaping (FoodItem) -> Void) {
        self.original = food
        self.onSave = onSave

        let existingQuantity = max(1, food.quantity)
        _quantity = State(initialValue: existingQuantity)
        _name = State(initialValue: food.name)
        // Derive per-unit macros from the stored totals so editing quantity
        // later scales macros consistently, same as a freshly logged food.
        _proteinText = State(initialValue: "\(food.protein / existingQuantity)")
        _carbsText = State(initialValue: "\(food.carbs / existingQuantity)")
        _fatsText = State(initialValue: "\(food.fats / existingQuantity)")
        _caloriesText = State(initialValue: "\(food.calories / existingQuantity)")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Form {
            Section("Food") {
                TextField("Name", text: $name)
            }

            Section("Macros per unit (optional)") {
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
                HStack {
                    Text("Quantity")
                    Spacer()
                    Text("\(quantity)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 24, alignment: .trailing)
                    Stepper("Quantity", value: $quantity, in: 1...100)
                        .labelsHidden()
                }
            }
        }
        .navigationTitle("Edit Food")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let proteinPerUnit = Int(proteinText) ?? 0
                    let carbsPerUnit = Int(carbsText) ?? 0
                    let fatsPerUnit = Int(fatsText) ?? 0
                    let caloriesPerUnit = Int(caloriesText) ?? 0

                    let updated = FoodItem(
                        id: original.id,
                        name: trimmedName,
                        protein: proteinPerUnit * quantity,
                        carbs: carbsPerUnit * quantity,
                        fats: fatsPerUnit * quantity,
                        calories: caloriesPerUnit * quantity,
                        quantity: quantity,
                        loggedAt: original.loggedAt
                    )
                    onSave(updated)
                    dismiss()
                }
                .disabled(trimmedName.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditFoodEntryView(
            food: FoodItem(name: "Rice", protein: 8, carbs: 90, fats: 0, calories: 410, quantity: 2)
        ) { _ in }
    }
}
