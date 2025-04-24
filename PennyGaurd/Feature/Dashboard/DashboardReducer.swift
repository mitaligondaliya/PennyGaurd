//
//  DashboardReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct DashboardReducer: Reducer {
    struct State: Equatable {
        var transactions: [Transaction] = []
        var isPresentingSheet = false
        var editorState: AddTransactionReducer.State? = nil
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
            let calendar = Calendar.current
            let now = Date()
            let startDate: Date?

            switch timeFrame {
            case .week:
                startDate = calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                startDate = calendar.date(byAdding: .month, value: -1, to: now)
            case .year:
                startDate = calendar.date(byAdding: .year, value: -1, to: now)
            case .all:
                startDate = nil
            }

            if let start = startDate {
                return transactions.filter { $0.date >= start }.sorted { $0.date > $1.date }
            } else {
                return transactions.sorted { $0.date > $1.date }
            }
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
        case transactionsLoaded([Transaction])
        case addButtonTapped
        case transactionTapped(Transaction)
        case sheetDismissed
        case editor(AddTransactionReducer.Action)
        case setTimeFrame(TimeFrame)
    }
    
    @Dependency(\.modelContext) var modelContext

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setTimeFrame(newTimeFrame):
                state.timeFrame = newTimeFrame
                return .none
                
            case .loadTransactions:
                let fetched = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
                return .send(.transactionsLoaded(fetched))

            case let .transactionsLoaded(transactions):
                state.transactions = transactions
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
                return .none

            case .editor(.saveCompleted), .editor(.deleteCompleted):
                state.editorState = nil
                state.isPresentingSheet = false
                return .send(.loadTransactions)

            case .editor:
                return .none
            }
        }
        .ifLet(\.editorState, action: \.editor) {
            AddTransactionReducer()
        }
    }
}
