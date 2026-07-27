//
//  LogView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//
import SwiftUI

struct LogView: View {
    var body: some View {
        NavigationStack {
            List {
                // Placeholder log
                Text("Jul 25 • Dinner: Pasta • Symptoms: Bloating (2)")
                Text("Jul 24 • Lunch: Sushi • Symptoms: Fatigue (1)")
            }
            .navigationTitle("Log")
        }
    }
}
