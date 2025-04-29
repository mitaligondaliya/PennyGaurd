//
//  Transactiondatabase.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 25/04/25.
//

import SwiftData
import ComposableArchitecture
import Foundation

// MARK: - Dependency Injection Key for SwiftData-based Transaction Database

extension DependencyValues {
    var swiftData: TransactionDatabase {
        get { self[TransactionDatabase.self] }
        set { self[TransactionDatabase.self] = newValue }
    }
}

// MARK: - TransactionDatabase Interface

struct TransactionDatabase {
    var fetchAll: @Sendable () throws -> [Transaction]       // Fetch all transactions
    var fetch: @Sendable (FetchDescriptor<Transaction>) throws -> [Transaction] // Fetch with a descriptor
    var add: @Sendable (Transaction) throws -> Void           // Add a transaction
    var delete: @Sendable (Transaction) throws -> Void        // Delete a transaction
    var update: @Sendable (Transaction) async throws -> Void  // Save changes to the database

    // MARK: - Transaction Errors

    enum TransactionError: Error {
        case add
        case delete
    }
}

// MARK: - Live Implementation

extension TransactionDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                // Access the SwiftData context and fetch all transactions sorted by date
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()

                let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
                return try transactionContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        fetch: { descriptor in
            do {
                // Fetch using a provided FetchDescriptor
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                return try transactionContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            do {
                // Insert a new transaction model into the context
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                transactionContext.insert(model)
            } catch {
                throw TransactionError.add
            }
        },
        delete: { model in
            do {
                // Delete the provided transaction model from the context
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                transactionContext.delete(model)
            } catch {
                throw TransactionError.delete
            }
        },
        update: { _ in
            do {
                // Save changes to the context
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                try transactionContext.save()
            } catch {
                throw TransactionError.add
            }
        }
    )
}

// MARK: - Preview / Test Implementation

extension TransactionDatabase: TestDependencyKey {
    public static var previewValue = Self.noop

    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetch"),
        fetch: unimplemented("\(Self.self).fetchDescriptor"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete"),
        update: unimplemented("\(Self.self).update")
    )

    /// No-op mock version used for previews
    static let noop = Self(
        fetchAll: { [] },
        fetch: { _ in [] },
        add: { _ in },
        delete: { _ in },
        update: { _ in }
    )
}
