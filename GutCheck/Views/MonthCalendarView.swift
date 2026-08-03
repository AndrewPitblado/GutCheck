//
//  MonthCalendarView.swift
//  GutCheck
//
//  Created by Andrew on 2026-08-03.
//
import SwiftUI

/// A lightweight month-grid calendar (no UIKit wrapping) that shows a colored
/// dot under any day that has a log, so users can spot patterns at a glance
/// and jump straight to a specific day instead of scrolling a long list.
struct MonthCalendarView: View {
    @Binding var displayedMonth: Date // any date within the shown month
    @Binding var selectedDate: Date
    let store: DayLogStore

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            header
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(gridDates.indices, id: \.self) { index in
                    if let date = gridDates[index] {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isFuture: date > calendar.startOfDay(for: Date()),
                            dayLog: store.dayLog(for: date)
                        ) {
                            withAnimation(.snappy) { selectedDate = date }
                        }
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.headline)

            Spacer()

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        return HStack {
            ForEach(Array(symbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(.snappy) { displayedMonth = newMonth }
        }
    }

    /// Full 6-row grid of the displayed month, padded with `nil` for the
    /// leading/trailing days that belong to adjacent months.
    private var gridDates: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstOfMonth = monthInterval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        // 1 (Sunday) ... 7 (Saturday) -> 0-indexed leading blanks
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = firstWeekday - calendar.firstWeekday
        let normalizedLeading = leadingBlanks < 0 ? leadingBlanks + 7 : leadingBlanks

        var dates: [Date?] = Array(repeating: nil, count: normalizedLeading)
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                dates.append(date)
            }
        }
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        return dates
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool
    let dayLog: DayLog
    let action: () -> Void

    private var dotColor: Color? {
        if let rating = dayLog.checkIn.overallRating {
            return rating.color
        } else if !dayLog.isEmpty {
            return .secondary
        }
        return nil
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date, format: .dateTime.day())
                    .font(.subheadline.weight(isToday ? .bold : .regular))
                    .monospacedDigit()
                    .frame(width: 30, height: 30)
                    .background(
                        Circle().fill(isSelected ? Color.accentColor : Color.clear)
                    )
                    .overlay(
                        Circle().stroke(isToday && !isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
                    )
                    .foregroundStyle(isSelected ? Color.white : (isFuture ? Color(.tertiaryLabel) : Color.primary))

                Circle()
                    .fill(dotColor ?? .clear)
                    .frame(width: 5, height: 5)
            }
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}

#Preview {
    MonthCalendarView(
        displayedMonth: .constant(Date()),
        selectedDate: .constant(Date()),
        store: DayLogStore()
    )
    .padding()
}
