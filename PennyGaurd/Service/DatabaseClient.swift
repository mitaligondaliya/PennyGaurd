//
//  Transactiondatabase.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 25/04/25.
//
import ComposableArchitecture
import SwiftData
import Foundation

// MARK: - Dependency Injection Key for SwiftData-based Transaction Database
extension DependencyValues {
    var swiftData: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

// MARK: - TransactionDatabase Interface
struct DatabaseClient {
    var fetchAll: () async throws -> [Transaction]       // Fetch all transactions
    var fetch: (FetchDescriptor<Transaction>) async throws -> [Transaction] // Fetch with a descriptor
    var add: (Transaction) async throws -> Void           // Add a transaction
    var deleteByID: (UUID) async throws -> Void  // Delete a transaction by ID
    var update: (Transaction) async throws -> Void  // Save changes to the database
    
    // MARK: - Transaction Errors
    enum TransactionError: Error {
        case add
        case delete
        case update
    }
}

// MARK: - Live Implementation
extension DatabaseClient: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                // Access the SwiftData context and fetch all transactions sorted by date
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                
                let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
                return try transactionContext.fetch(descriptor)
            } catch {
                print("Failed to fetch transactions: \(error)")
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
                print("Failed to fetch transactions: \(error)")
                return []
            }
        },
        add: { model in
            do {
                // Insert a new transaction model into the context
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                transactionContext.insert(model)
                try transactionContext.save()  // Ensure save is called after adding
            } catch {
                print("Failed to add transactions: \(error)")
                throw TransactionError.add
            }
        },
        deleteByID: { id in
            @Dependency(\.databaseService.context) var context
            let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.id == id })
            if let transaction = try context().fetch(descriptor).first {
                let transactionContext = try context()
                transactionContext.delete(transaction)
                try transactionContext.save()
            } else {
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
                print("Failed to update transaction: \(error)")
                throw TransactionError.update
            }
        }
    )
}

// MARK: - Preview / Test Implementation
extension DatabaseClient: TestDependencyKey {
    public static var previewValue = Self.noop
    
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetchAll"),
        fetch: unimplemented("\(Self.self).fetchDescriptor"),
        add: unimplemented("\(Self.self).Add"),
        deleteByID: unimplemented("\(Self.self).delete"),
        update: unimplemented("\(Self.self).update")
    )
    
    /// No-op mock version used for previews
    static let noop = Self(
        fetchAll: { [] },
        fetch: { _ in [] },
        add: { _ in },
        deleteByID: { _ in },
        update: { _ in }
    )
 }
