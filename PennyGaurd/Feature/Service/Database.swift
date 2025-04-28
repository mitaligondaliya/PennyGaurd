//
//  Database.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 25/04/25.
//

import SwiftData
import ComposableArchitecture
import Dependencies
import Foundation

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

fileprivate let appContext: ModelContext = {
    do {
        
        let container = try ModelContainer(for: Transaction.self)
        return ModelContext(container)
    } catch {
        fatalError("Failed to create container.")
    }
}()

struct Database {
    var context: () throws -> ModelContext
}

extension Database: DependencyKey {
    public static let liveValue = Self(
        context: { appContext }
    )
}

extension Database: TestDependencyKey {
    public static var previewValue = Self.noop
    
    public static let testValue = Self(
        context: unimplemented("\(Self.self).context")
    )
    
    static let noop = Self(
        context: unimplemented("\(Self.self).context")
    )
}
