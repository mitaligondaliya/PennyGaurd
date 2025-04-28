//
//  Transactiondatabase.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 25/04/25.
//

import SwiftData
import ComposableArchitecture
import Foundation

extension DependencyValues {
    var swiftData: TransactionDatabase {
        get { self[TransactionDatabase.self] }
        set { self[TransactionDatabase.self] = newValue }
    }
}

struct TransactionDatabase {
    var fetchAll: @Sendable () throws -> [Transaction]
    var fetch: @Sendable (FetchDescriptor<Transaction>) throws -> [Transaction]
    var add: @Sendable (Transaction) throws -> Void
    var delete: @Sendable (Transaction) throws -> Void
    var update: @Sendable (Transaction) async throws -> Void // Add this method
    
    enum TransactionError: Error {
        case add
        case delete
    }
}

extension TransactionDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
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
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                return try transactionContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                
                transactionContext.insert(model)
            } catch {
                throw TransactionError.add
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                
                let modelToBeDelete = model
                transactionContext.delete(modelToBeDelete)
            } catch {
                throw TransactionError.delete
            }
        },
        update: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let transactionContext = try context()
                
                try transactionContext.save()
            } catch {
                throw TransactionError.add
            }
        }
    )
}

extension TransactionDatabase: TestDependencyKey {
    public static var previewValue = Self.noop
    
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetch"),
        fetch: unimplemented("\(Self.self).fetchDescriptor"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete"),
        update: unimplemented("\(Self.self).update")
    )
    
    static let noop = Self(
        fetchAll: { [] },
        fetch: { _ in [] },
        add: { _ in },
        delete: { _ in },
        update: { _ in }
    )
}
