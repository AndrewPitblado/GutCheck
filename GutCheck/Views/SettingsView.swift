//
//  SettingsView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Privacy") {
                    Toggle("Lock with Face ID", isOn: .constant(false))
                }
                Section("Account") {
                    Text("Not signed in")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
