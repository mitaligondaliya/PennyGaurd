//
//  TransactionListReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct TransactionReducer: Reducer {
    struct State: Equatable {
        var transactions: [Transaction] = []
        var isPresentingSheet = false
        var editorState: AddTransactionReducer.State?
        var timeFrame: TimeFrame = .month
        
        var totalIncome: Double {
            transactions.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        }

        var totalExpense: Double {
            transactions.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        }

        var balance: Double {
            totalIncome - totalExpense
        }

        var filteredTransactions: [Transaction] {
            let startDate = timeFrame.startDate
            return transactions
                .filter { startDate == nil || $0.date >= startDate! }
                .sorted { $0.date > $1.date }
        }

        var expensesByCategory: [Category: Double] {
            var result: [Category: Double] = [:]
            for transaction in filteredTransactions where transaction.type == .expense {
                result[transaction.category, default: 0] += transaction.amount
            }
            return result
        }
    }

    @CasePathable
    enum Action: Equatable {
        case loadTransactions
        case addButtonTapped
        case transactionTapped(Transaction)
        case sheetDismissed
        case editor(AddTransactionReducer.Action)
        case delete(IndexSet)
        case setTimeFrame(TimeFrame)
    }

    @Dependency(\.swiftData) var context
    @Dependency(\.databaseService) var databaseService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setTimeFrame(newTimeFrame):
                state.timeFrame = newTimeFrame
                return .send(.loadTransactions) // Reload transactions when time frame changes

            case .loadTransactions:
                do {
                    state.transactions = try context.fetchAll()
                    // Optionally filter transactions based on the time frame here
                } catch {
                    print("Failed to load transactions: \(error)")
                }
                return .none

            case .addButtonTapped:
                state.editorState = AddTransactionReducer.State()
                state.isPresentingSheet = true
                return .none

            case let .transactionTapped(transaction):
                state.editorState = AddTransactionReducer.State(existing: transaction)
                state.isPresentingSheet = true
                return .none

            case .sheetDismissed:
                state.isPresentingSheet = false
                state.editorState = nil // Clear editor state when the sheet is dismissed
                return .none

            case .editor(.saveCompleted):
                state.editorState = nil
                state.isPresentingSheet = false
                return .send(.loadTransactions) // Reload transactions after saving

            case .editor:
                return .none

            case let .delete(indexSet):
                // Delete selected transactions
                for index in indexSet {
                    let transaction = state.transactions[index]
                    do {
                        try context.delete(transaction)
                        // Optionally remove from state if deletion is successful
                        state.transactions.remove(at: index)
                    } catch {
                        print("Failed to delete transaction: \(error)")
                    }
                }
                return .none
            }
        }
        .ifLet(\.editorState, action: \.editor) {
            AddTransactionReducer()
        }
    }
}

extension TimeFrame {
    var startDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now)
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now)
        case .all:
            return nil
        }
    }
}
