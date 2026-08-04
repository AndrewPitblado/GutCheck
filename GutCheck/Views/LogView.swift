//
//  LogView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//
import SwiftUI

private enum LogViewMode: String, CaseIterable, Identifiable {
    case list = "List"
    case calendar = "Calendar"
    var id: String { rawValue }
}

struct LogView: View {
    @EnvironmentObject private var store: DayLogStore

    @State private var viewMode: LogViewMode = .list
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Date()

    private var days: [DayLog] {
        store.sortedDays
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewMode {
                case .list:
                    listContent
                case .calendar:
                    calendarContent
                }
            }
            .navigationTitle("Log")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("View", selection: $viewMode.animation(.snappy)) {
                        ForEach(LogViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }
            }
        }
    }

    @ViewBuilder
    private var listContent: some View {
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

    private var calendarContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                MonthCalendarView(
                    displayedMonth: $displayedMonth,
                    selectedDate: $selectedDate,
                    store: store
                )
                .padding(.horizontal)

                selectedDayPreview
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var selectedDayPreview: some View {
        let day = store.dayLog(for: selectedDate)
        return NavigationLink {
            DayDetailView(date: selectedDate)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(selectedDate, format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                if day.isEmpty {
                    Label("No entries for this day — tap to log", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    DayLogRow(day: day)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(.thinMaterial))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.quaternary, lineWidth: 1))
        }
        .buttonStyle(.plain)
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
    let context = PersistenceSchema.previewContext()
    return LogView()
        .environmentObject(DayLogStore(context: context))
        .environmentObject(FoodCatalogStore(context: context))
}
