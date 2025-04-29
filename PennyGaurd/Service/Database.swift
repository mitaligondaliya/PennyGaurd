//
//  Database.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 25/04/25.
//

import SwiftData
import ComposableArchitecture
import Foundation

// MARK: - Dependency Key for ModelContext Access
extension DependencyValues {
    var databaseService: DatabaseService {
        get { self[DatabaseService.self] }
        set { self[DatabaseService.self] = newValue }
    }
}

// MARK: - Concrete ModelContext Setup (Used in Live App)
private let appContext: ModelContext = {
    do {
        let container = try ModelContainer(for: Transaction.self)
        return ModelContext(container)
    } catch {
        fatalError("Failed to create container.")
    }
}()

// MARK: - DatabaseService Type Definition
struct DatabaseService {
    var context: () throws -> ModelContext
}

// MARK: - Live Value for Dependency
extension DatabaseService: DependencyKey {
    static let liveValue = Self(
        context: { appContext }
    )
}

// MARK: - Preview/Test Support
extension DatabaseService: TestDependencyKey {
    static var previewValue = Self.noop

    static let testValue = Self(
        context: unimplemented("\(Self.self).context")
    )

    static let noop = Self(
        context: unimplemented("\(Self.self).context")
    )
}
