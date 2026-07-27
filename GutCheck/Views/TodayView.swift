//
//  TodayView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct TodayView: View {
    @State private var showingAddEntry = false

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    // Placeholder entries
                    Text("Breakfast: Oatmeal, Banana")
                    Text("Lunch: Chicken Salad")
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add Entry")
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                NavigationStack {
                    AddEntryView()
                }
            }
        }
    }
}
