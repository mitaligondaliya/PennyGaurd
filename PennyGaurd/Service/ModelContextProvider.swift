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
    var context: () throws -> ModelContext // This returns the ModelContext for direct access
}

// MARK: - Live Value for Dependency
extension DatabaseService: DependencyKey {
    static let liveValue = Self(
        context: { appContext }
    )
}

// MARK: - Preview/Test Support
extension DatabaseService: TestDependencyKey {
    static let testValue = Self(
        context: {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(for: Transaction.self, configurations: config)
                print("ModelContainer created successfully")
                let context = ModelContext(container)
                print("ModelContext created successfully")
                return context
            } catch {
                // fatalError("Failed to create in-memory ModelContainer: \(error)")
                // Log the error instead of fatalError
                print("Error creating in-memory ModelContext: \(error)")
                throw error
            }
        }
    )
}
