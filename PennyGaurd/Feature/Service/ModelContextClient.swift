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

let previewContainer: ModelContainer = {
    do {
        let schema = Schema([Transaction.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}()
