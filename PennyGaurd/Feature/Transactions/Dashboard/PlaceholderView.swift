//
//  PlaceholderView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 23/04/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - PlaceholderView
struct PlaceholderView: View {
    let message: String               // Message to display
    var addAction: (() -> Void)?     // Optional action for the add button

    var body: some View {
        VStack(spacing: 12) {
            // Show a "plus" icon button if an addAction is provided
            if let addAction = addAction {
                Button(action: addAction) {
                    Image(systemName: "plus.bubble")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Display the placeholder message
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150) // Stretch to fill horizontally and ensure some vertical space
        .padding()
    }
}

// MARK: - Preview
#Preview {
    PlaceholderView(
        message: "No data"
    ) {}
}
