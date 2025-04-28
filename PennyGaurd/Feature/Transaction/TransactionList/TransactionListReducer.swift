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
        var editorState: AddTransactionReducer.State?
    }

    @CasePathable
    enum Action: Equatable {
        case loadTransactions
        case addButtonTapped
        case transactionTapped(Transaction)
        case sheetDismissed
        case editor(AddTransactionReducer.Action)
        case delete(IndexSet)
    }

    @Dependency(\.swiftData) var context
    @Dependency(\.databaseService) var databaseService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadTransactions:
                do {
                    state.transactions  = try context.fetchAll()
                } catch {}
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

            case .editor(.saveCompleted):
                state.editorState = nil
                state.isPresentingSheet = false
                return .send(.loadTransactions)

            case .editor:
                return .none

            case let .delete(indexSet):
                for index in indexSet {
                    let transaction = state.transactions[index]
                    do {
                        try context.delete(transaction)
                    } catch {

                    }
                }
                return .run { @MainActor send in
                    send(.loadTransactions)
                }
            }
        }
        .ifLet(\.editorState, action: \.editor) {
            AddTransactionReducer()
        }
    }
}
