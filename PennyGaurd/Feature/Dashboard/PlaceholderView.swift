//
//  PlaceholderView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 23/04/25.
//

import SwiftUI
import ComposableArchitecture

struct PlaceholderView: View {
    let message: String
    var addAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            if let addAction = addAction {
                Button(action: addAction) {
                    Image(systemName: "plus.bubble")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding()
    }
}

#Preview {
    PlaceholderView(
        message: "No data") { }
}

