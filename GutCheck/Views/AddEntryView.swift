import SwiftUI


struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (MealType, [FoodItem]) -> Void
    @State private var selectedMeal: MealType
    @State private var foodText: String = ""
    @State private var items: [String] = []

    // Macro inputs actually captured now (previously bound to .constant(""))
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatsText: String = ""
    @State private var caloriesText: String = ""

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

    var body: some View {
        Form {
            Picker("Meal", selection: $selectedMeal) {
                ForEach(MealType.allCases) { Text($0.title).tag($0) }
            }
            HStack {
                TextField("Add a food (e.g., Rice)", text: $foodText)
                Button("Add") {
                    let trimmed = foodText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    items.append(trimmed)
                    foodText = ""
                }
                .disabled(foodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            if items.isEmpty {
                Text("No foods yet").foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.self) { Text($0) }
                    .onDelete { indices in items.remove(atOffsets: indices) }
            }
        }
        .navigationTitle("Log Entry")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let loggedAt = Date()
                    let protein = Int(proteinText) ?? 0
                    let carbs = Int(carbsText) ?? 0
                    let fats = Int(fatsText) ?? 0
                    let calories = Int(caloriesText) ?? 0
                    let foods = items.map {
                        FoodItem(name: $0, protein: protein, carbs: carbs, fats: fats, calories: calories, loggedAt: loggedAt)
                    }
                    onSave(selectedMeal, foods)
                    dismiss()
                }
                .disabled(items.isEmpty)
            }
        }
    }
}

