//
//  FoodsView.swift
//  GutCheck
//
//  Created by Andrew on 2026-07-26.
//

import SwiftUI

struct FoodsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Favorites") {
                    Text("Rice")
                    Text("Chicken")
                }
                Section("Avoid") {
                    Text("Dairy")
                    Text("Broccoli")
                }
            }
            .navigationTitle("Foods")
        }
    }
}
