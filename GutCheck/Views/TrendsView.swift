//
//  TrendsView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct TrendsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Trends & Insights")
                    .font(.headline)
                Text("Charts will appear here once you start logging.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Trends")
        }
    }
}
