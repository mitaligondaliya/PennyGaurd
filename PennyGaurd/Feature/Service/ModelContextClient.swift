//
//  ModelContextClient.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import SwiftData
import ComposableArchitecture

private enum ModelContextKey: DependencyKey {
    static let liveValue: ModelContext = {
        fatalError("ModelContext not injected.")
    }()
}

extension DependencyValues {
    var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }
}
