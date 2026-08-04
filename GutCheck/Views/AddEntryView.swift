import SwiftUI


struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var catalog: FoodCatalogStore

    let onSave: (MealType, [FoodItem]) -> Void
    @State private var selectedMeal: MealType
    @State private var foodText: String = ""
    @State private var items: [FoodItem] = []

    // Per-unit macro inputs, captured per-food at the moment "Add" is tapped.
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatsText: String = ""
    @State private var caloriesText: String = ""
    @State private var quantity: Int = 1

    /// Whether the food currently being typed should also be saved to the
    /// Foods catalog for quick reuse next time. Defaults on for brand new
    /// foods and is hidden once the name matches something already saved.
    @State private var rememberFood = true

    @FocusState private var isFoodFieldFocused: Bool

    init(onSave: @escaping (MealType, [FoodItem]) -> Void) {
        self.onSave = onSave
        _selectedMeal = State(initialValue: Self.suggestedMeal(for: Date()))
    }

    /// Suggests the most likely meal based on the current time of day,
    /// so users don't have to re-pick it every time they open the sheet.
    private static func suggestedMeal(for date: Date) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 4..<11: return .breakfast
        case 11..<15: return .lunch
        case 15..<17: return .snack
        case 17..<22: return .dinner
        default: return .snack
        }
    }

    private var trimmedFoodText: String {
        foodText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Catalog foods matching what's currently typed, shown as tappable
    /// autocomplete suggestions while the food field is focused.
    private var suggestions: [SavedFood] {
        guard isFoodFieldFocused, !trimmedFoodText.isEmpty else { return [] }
        return Array(catalog.matching(trimmedFoodText).prefix(5))
    }

    private var matchesExistingCatalogFood: Bool {
        catalog.firstMatch(named: trimmedFoodText) != nil
    }

    private func selectSuggestion(_ food: SavedFood) {
        foodText = food.name
        proteinText = "\(food.protein)"
        carbsText = "\(food.carbs)"
        fatsText = "\(food.fats)"
        caloriesText = "\(food.calories)"
        quantity = food.quantity
        isFoodFieldFocused = false
    }

    private func addCurrentFood() {
        guard !trimmedFoodText.isEmpty else { return }
        let loggedQuantity = max(1, quantity)
        let proteinPerUnit = Int(proteinText) ?? 0
        let carbsPerUnit = Int(carbsText) ?? 0
        let fatsPerUnit = Int(fatsText) ?? 0
        let caloriesPerUnit = Int(caloriesText) ?? 0

        items.append(
            FoodItem(
                name: trimmedFoodText,
                protein: proteinPerUnit * loggedQuantity,
                carbs: carbsPerUnit * loggedQuantity,
                fats: fatsPerUnit * loggedQuantity,
                calories: caloriesPerUnit * loggedQuantity,
                quantity: loggedQuantity
            )
        )

        if rememberFood, !matchesExistingCatalogFood {
            catalog.add(
                SavedFood(
                    name: trimmedFoodText,
                    protein: proteinPerUnit,
                    carbs: carbsPerUnit,
                    fats: fatsPerUnit,
                    calories: caloriesPerUnit,
                    quantity: loggedQuantity
                )
            )
        }

        foodText = ""
        proteinText = ""
        carbsText = ""
        fatsText = ""
        caloriesText = ""
        quantity = 1
        rememberFood = true
    }

    var body: some View {
        Form {
            Picker("Meal", selection: $selectedMeal) {
                ForEach(MealType.allCases) { Text($0.title).tag($0) }
            }
            HStack {
                TextField("Add a food (e.g., Rice)", text: $foodText)
                    .focused($isFoodFieldFocused)
                Button("Add", action: addCurrentFood)
                    .disabled(trimmedFoodText.isEmpty)
            }

            if !suggestions.isEmpty {
                Section {
                    ForEach(suggestions) { food in
                        Button {
                            selectSuggestion(food)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(food.name)
                                        .foregroundStyle(.primary)
                                    if food.calories > 0 {
                                        Text("\(food.calories) kcal · P\(food.protein) C\(food.carbs) F\(food.fats)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
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
                        }
                    }
                } header: {
                    Text("From Your Foods")
                }
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
                if !trimmedFoodText.isEmpty && !matchesExistingCatalogFood {
                    Toggle("Remember in Foods list", isOn: $rememberFood)
                }
            }
            if items.isEmpty {
                Text("No foods yet").foregroundStyle(.secondary)
            } else {
                ForEach(items) { food in
                    HStack {
                        Text(food.name)
                        if food.calories > 0 {
                            Spacer()
                            Text("\(food.calories) kcal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indices in items.remove(atOffsets: indices) }
            }
        }
        .navigationTitle("Log Entry")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(selectedMeal, items)
                    dismiss()
                }
                .disabled(items.isEmpty)
            }
        }
    }
}

