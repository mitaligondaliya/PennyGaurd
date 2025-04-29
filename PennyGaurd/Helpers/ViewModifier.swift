//
//  ViewModifier.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 21/04/25.
//

import SwiftUI

// MARK: - CardStyle View Modifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()  // Add padding around the content
            .frame(maxWidth: .infinity, alignment: .leading)  // Make the content fill the width
            .background(
                // Background with rounded corners and shadow
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))  // Use secondary system background color
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 4, y: 4)  // Apply shadow for depth effect
            )
    }
}

extension View {
    // MARK: - CardStyle Modifier Extension
    func cardStyle() -> some View {
        self.modifier(CardStyle())  // Apply the CardStyle view modifier to the view
    }
}
