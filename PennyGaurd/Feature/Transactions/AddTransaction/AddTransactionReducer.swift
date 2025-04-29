//
//  AddTransactionReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

// MARK: - AddTransactionReducer
/// Reducer for managing the state and actions related to adding or editing a transaction.
struct AddTransactionReducer: Reducer {
    
    // MARK: - State
    /// The state representing the data for adding or editing a transaction.
    @ObservableState
    struct State: Equatable {
        var transaction: Transaction? // Existing transaction, if any
        var title: String = ""
        var amount: Double = 0.0
        var date: Date = .now
        var notes: String = ""
        var type: CategoryType = .expense
        var selectedCategory: Category = .other
        var hasInitializedCategory = false

        var isEditing: Bool { transaction != nil } // Whether editing an existing transaction

        init() {}

        /// Initializer for editing an existing transaction.
        init(existing transaction: Transaction) {
            self.transaction = transaction
            self.title = transaction.title
            self.amount = transaction.amount
            self.date = transaction.date
            self.notes = transaction.notes ?? ""
            self.type = transaction.type
            self.selectedCategory = transaction.category
            self.hasInitializedCategory = true // Prevent auto-select of category when editing
        }
    }

    // MARK: - Action
    enum Action: Equatable {
        case titleChanged(String)
        case amountChanged(Double)
        case dateChanged(Date)
        case notesChanged(String)
        case typeChanged(CategoryType)
        case categorySelected(Category)
        case cancelTapped
        case saveTapped
        case saveCompleted
    }

    // MARK: - Dependencies
    @Dependency(\.swiftData) var context
    @Dependency(\.databaseService) var databaseService

    // MARK: - Reducer Logic
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .titleChanged(newTitle):
            state.title = newTitle
            return .none

        case let .amountChanged(newAmount):
            state.amount = newAmount
            return .none

        case let .dateChanged(newDate):
            state.date = newDate
            return .none

        case let .notesChanged(newNotes):
            state.notes = newNotes
            return .none

        case let .typeChanged(newType):
            state.type = newType
            if !state.hasInitializedCategory {
                // If category isn't initialized, set the first matching category for this type
                if let first = Category.allCases.first(where: { $0.type == newType }) {
                    state.selectedCategory = first
                    state.hasInitializedCategory = true // Prevent re-initializing category
                }
            }
            return .none

        case let .categorySelected(category):
            state.selectedCategory = category // Update selected category
            return .none

        case .saveTapped:
            // Save transaction: either edit existing or create a new one
            if let editing = state.transaction {
                editing.title = state.title
                editing.amount = state.amount
                editing.date = state.date
                editing.notes = state.notes
                editing.category = state.selectedCategory
                editing.type = state.type
            } else {
                let new = Transaction(
                    title: state.title,
                    amount: state.amount,
                    date: state.date,
                    notes: state.notes,
                    category: state.selectedCategory,
                    type: state.type
                )

                do {
                    try context.add(new) // Add new transaction to context
                } catch {
                    print("Failed to add transaction to context: \(error)")
                }
            }

            // Save context changes
            guard let context = try? self.databaseService.context() else {
                print("Failed to find context")
                return .none
            }
            do {
                try context.save() // Save the changes to the database
                return .send(.saveCompleted) // Indicate that save is completed
            } catch {
                print("Failed to save context: \(error)")
            }
            return .none

        case .saveCompleted, .cancelTapped:
            return .none // No action needed for cancel or save completion
        }
    }
}
