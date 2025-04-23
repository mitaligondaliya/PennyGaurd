//
//  TransactionListReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct TransactionListReducer: Reducer {
    struct State: Equatable {
        var transactions: [Transaction] = []
        var isPresentingSheet = false
        var editorState: AddTransactionReducer.State? = nil
    }

    enum Action: Equatable {
        case loadTransactions
        case transactionsLoaded([Transaction])
        case addButtonTapped
        case transactionTapped(Transaction)
        case sheetDismissed
        case editor(AddTransactionReducer.Action)
        case delete(IndexSet)
    }

    @Dependency(\.modelContext) var modelContext

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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

            case let .delete(indexSet):
                for index in indexSet {
                    let transaction = state.transactions[index]
                    modelContext.delete(transaction)
                }
                try? modelContext.save()
                return .send(.loadTransactions)
            }
        }
        .ifLet(\.editorState, action: /Action.editor) {
            AddTransactionReducer()
        }
    }
}
