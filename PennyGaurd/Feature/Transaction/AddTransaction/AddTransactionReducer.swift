//
//  AddTransactionReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

struct AddTransactionReducer: Reducer {
    struct State: Equatable {
        var transaction: Transaction?
        var title: String = ""
        var amount: Double = 0.0
        var date: Date = .now
        var notes: String = ""
        var type: CategoryType = .expense
        var selectedCategory: Category = .other
        var hasInitializedCategory = false

        var isEditing: Bool {
            transaction != nil
        }

        init() {}

        init(existing transaction: Transaction) {
            self.transaction = transaction
            self.title = transaction.title
            self.amount = transaction.amount
            self.date = transaction.date
            self.notes = transaction.notes ?? ""
            self.type = transaction.type
            self.selectedCategory = transaction.category
            self.hasInitializedCategory = true  // <— prevent auto-select
        }
    }

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

    @Dependency(\.swiftData) var context
    @Dependency(\.databaseService) var databaseService

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
            // If not yet initialized, set the first matching category
            if !state.hasInitializedCategory {
                if let first = Category.allCases.first(where: { $0.type == newType }) {
                    state.selectedCategory = first
                    state.hasInitializedCategory = true
                }
            }
            return .none

        case let .categorySelected(category):
            state.selectedCategory = category
            return .none

        case .saveTapped:
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
                    try context.add(new)
                } catch {}
            }
            guard let context = try? self.databaseService.context() else {
                print("Failed to find context")
                return .none
            }
            do {
                try context.save()
                return .send(.saveCompleted)
            } catch {
                print("Failed to save")
            }
            return .none

        case .saveCompleted, .cancelTapped:
            return .none
        }
    }
}
