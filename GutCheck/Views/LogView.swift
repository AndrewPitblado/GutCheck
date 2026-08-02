//
//  LogView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//
import SwiftUI

struct LogView: View {
    @EnvironmentObject private var store: DayLogStore

    private var days: [DayLog] {
        store.sortedDays
    }

    var body: some View {
        NavigationStack {
            Group {
                if days.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "calendar.badge.clock",
                        description: Text("Days you log from Today will show up here.")
                    )
                } else {
                    List(days) { day in
                        NavigationLink {
                            DayDetailView(date: day.date)
                        } label: {
                            DayLogRow(day: day)
                        }
                    }
                }
            }
            .navigationTitle("Log")
        }
    }
}

private struct DayLogRow: View {
    let day: DayLog

    private var isToday: Bool {
        Calendar.current.isDateInToday(day.date)
    }

    private var mealSummary: String {
        let loggedMeals = day.loggedMeals
        guard !loggedMeals.isEmpty else { return "No meals logged" }
        return loggedMeals.map(\.title).joined(separator: ", ")
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(day.date, format: .dateTime.weekday(.abbreviated).month().day())
                        .font(.subheadline.weight(.semibold))
                    if isToday {
                        Text("Today")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text(mealSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if day.checkIn.hasNotes {
                    Text(day.checkIn.notes)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                if let rating = day.checkIn.overallRating {
                    Text(rating.emoji)
                        .font(.title3)
                }
                if day.totalCalories > 0 {
                    Text("\(day.totalCalories) kcal")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LogView()
        .environmentObject(DayLogStore())
}
