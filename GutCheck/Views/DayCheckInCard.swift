//
//  DayCheckInCard.swift
//  GutCheck
//
//  Created by Andrew on 2026-08-01.
//

import SwiftUI

// Note: `SymptomRating` is already defined in MealCardView.swift and is
// reused here for the day-level rating, so it isn't redeclared in this file.

/// Day-level gut check-in: overall score plus freeform notes
/// (stress, sleep, travel, etc.) that aren't tied to a single meal.
struct DayCheckIn: Equatable {
    var overallRating: SymptomRating?
    var notes: String = ""

    var hasNotes: Bool {
        !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isEmpty: Bool {
        overallRating == nil && !hasNotes
    }
}

struct DayCheckInCard: View {
    @Binding var checkIn: DayCheckIn
    @FocusState private var notesFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("How's your gut today?")
                    .font(.headline)
                Spacer(minLength: 8)
                if let rating = checkIn.overallRating {
                    Text(rating.emoji)
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }

            HStack(spacing: 8) {
                ForEach(SymptomRating.allCases) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            checkIn.overallRating = (checkIn.overallRating == option) ? nil : option
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(option.emoji)
                                .font(.title2)
                            Text(option.title)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(checkIn.overallRating == option ? option.color.opacity(0.25) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    checkIn.overallRating == option ? option.color : Color.secondary.opacity(0.15),
                                    lineWidth: checkIn.overallRating == option ? 1.5 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.title)
                    .accessibilityAddTraits(checkIn.overallRating == option ? .isSelected : [])
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                ZStack(alignment: .topLeading) {
                    if checkIn.notes.isEmpty && !notesFocused {
                        Text("Stress, sleep, travel, period, workout…")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $checkIn.notes)
                        .focused($notesFocused)
                        .font(.subheadline)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 72, maxHeight: 120)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemFill))
                )
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

#Preview {
    DayCheckInCard(checkIn: .constant(DayCheckIn()))
        .padding()
}
