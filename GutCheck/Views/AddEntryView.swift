import SwiftUI


struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMeal: MealType = .breakfast
    @State private var foodText: String = ""
    @State private var items: [String] = []

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
            ToolbarItem(placement: .confirmationAction) { Button("Save") { dismiss() } }
        }
    }
}
