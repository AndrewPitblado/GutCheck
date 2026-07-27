//
//  AddEntryView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI
enum Symptom: String, CaseIterable, Identifiable, Codable {
    case abdominalPain = "Abdominal Pain"
    case bloating = "Bloating"
    case diarrhea = "Diarrhea"
    case constipation = "Constipation"
    case nausea = "Nausea"
    case fatigue = "Fatigue"

    var id: String { rawValue }
}

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var foodText = ""
    @State private var foods: [String] = []
    @State private var symptomSeverity: [Symptom: Int] = [:]
    @State private var notes = ""

    private let severityRange = 0...5

    var body: some View {
        Form {
            DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])

            Section("Foods") {
                HStack {
                    TextField("Add a food (e.g., Chicken, Rice)", text: $foodText)
                        .textInputAutocapitalization(.words)
                    Button("Add") {
                        let trimmed = foodText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        foods.append(trimmed)
                        foodText = ""
                    }
                    .disabled(foodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if foods.isEmpty {
                    Text("No foods added yet").foregroundStyle(.secondary)
                } else {
                    ForEach(foods, id: \.self) { food in
                        Text(food)
                    }
                    .onDelete { indices in
                        foods.remove(atOffsets: indices)
                    }
                }
            }

            Section("Symptoms") {
                ForEach(Symptom.allCases) { symptom in
                    HStack {
                        Text(symptom.rawValue)
                        Spacer()
                        Stepper(value: Binding(
                            get: { symptomSeverity[symptom] ?? 0 },
                            set: { symptomSeverity[symptom] = $0 }
                        ), in: severityRange) {
                            Text("\(symptomSeverity[symptom] ?? 0)")
                                .monospacedDigit()
                                .frame(width: 24, alignment: .trailing)
                        }
                        .labelsHidden()
                    }
                }
            }

            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle("New Entry")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // Later: persist to SwiftData
                    dismiss()
                }
                .disabled(foods.isEmpty && (symptomSeverity.values.allSatisfy { $0 == 0 }))
            }
        }
    }
}
