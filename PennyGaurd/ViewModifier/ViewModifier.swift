//
//  ViewModifier.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 21/04/25.
//

import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 4, y: 4)
                )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}
