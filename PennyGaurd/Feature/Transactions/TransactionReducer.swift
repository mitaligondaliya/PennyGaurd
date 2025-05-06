//
//  TransactionListReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

// MARK: - SortOption
enum SortOption: String, CaseIterable, Equatable {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending
    case titleAscending
    case titleDescending
    
    var displayName: String {
        switch self {
        case .dateDescending: return "Date ↓"
        case .dateAscending: return "Date ↑"
        case .amountDescending: return "Amount ↓"
        case .amountAscending: return "Amount ↑"
        case .titleAscending: return "Title A-Z"
        case .titleDescending: return "Title Z-A"
        }
    }
}

// MARK: - TransactionReducer
struct TransactionReducer: Reducer {
    
    // MARK: - State
    struct State: Equatable {
        var transactions: [Transaction] = []
        var isPresentingSheet = false
        var editorState: AddTransactionReducer.State?
        var timeFrame: TimeFrame = .month
        var searchString: String = ""
        var sortOption: SortOption = .dateDescending
        var errorMessage: String = ""
        
        // Computed properties
        var totalIncome: Double {
            transactions.filter { $0.type == .income }
                .map(\.amount)
                .reduce(0, +)
        }
        
        var totalExpense: Double {
            transactions.filter { $0.type == .expense }
                .map(\.amount)
                .reduce(0, +)
        }
        
        var balance: Double {
            totalIncome - totalExpense
        }
        
        // Filtered & sorted list of transactions
        var filteredTransactions: [Transaction] {
            var filtered = transactions
            let startDate = timeFrame.startDate
            
            // Filter by date
            if let startDate {
                filtered = filtered.filter { $0.date >= startDate }
            }
            
            // Filter by search text
            if !searchString.isEmpty {
                filtered = filtered.filter {
                    $0.title.localizedCaseInsensitiveContains(searchString) ||
                    $0.category.displayName.localizedCaseInsensitiveContains(searchString)
                }
            }
            
            // Apply sorting
            switch sortOption {
            case .dateDescending: return filtered.sorted { $0.date > $1.date }
            case .dateAscending: return filtered.sorted { $0.date < $1.date }
            case .amountDescending: return filtered.sorted { $0.amount > $1.amount }
            case .amountAscending: return filtered.sorted { $0.amount < $1.amount }
            case .titleAscending: return filtered.sorted { $0.title.lowercased() < $1.title.lowercased() }
            case .titleDescending: return filtered.sorted { $0.title.lowercased() > $1.title.lowercased() }
            }
        }
        
        // Expense totals grouped by category
        var expensesByCategory: [CategoryType: Double] {
            var result: [CategoryType: Double] = [:]
            for transaction in filteredTransactions where transaction.type == .expense {
                result[transaction.category, default: 0] += transaction.amount
            }
            return result
        }
    }
    
    // MARK: - Action
    @CasePathable
    enum Action: Equatable {
        case loadTransactions
        case transactionsLoadedSuccess([Transaction])
        case transactionsLoadedFailure(String)
        case addButtonTapped
        case transactionTapped(Transaction)
        case sheetDismissed
        case editor(AddTransactionReducer.Action)
        case delete(IndexSet)
        case deleteSuccess(index: Int)
        case deleteFailed(String)
        case setTimeFrame(TimeFrame)
        case searchTextChanged(String)
        case sortOptionChanged(SortOption)
    }
    
    // MARK: - Dependencies
    @Dependency(\.swiftData) var transactionDB
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .setTimeFrame(newTimeFrame):
                state.timeFrame = newTimeFrame
                return .none
                
            case .loadTransactions:
                return .run { send in
                    do {
                        let transactions = try await transactionDB.fetchAll()
                        await send(.transactionsLoadedSuccess(transactions))
                    } catch {
                        await send(.transactionsLoadedFailure("Fetch failed"))
                    }
                }
            case let .transactionsLoadedSuccess(result):
                state.transactions = result
                return .none
            case let .transactionsLoadedFailure(message):
                print("❌ Failed to load transactions: \(message)")
                state.errorMessage = message
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
                state.editorState = nil
                return .none
                
            case .editor(.saveCompleted):
                state.editorState = nil
                state.isPresentingSheet = false
                return .send(.loadTransactions) // Reload data after save
                
            case .editor:
                return .none
                
            case let .delete(indexSet):
                guard let index = indexSet.first else { return .none }
                let transaction = state.transactions[index]
                let id = transaction.id
                
                return .run { [id] send in
                    do {
                        try await transactionDB.deleteByID(id)
                        await send(.deleteSuccess(index: index))
                    } catch {
                        await send(.deleteFailed("Delete failed"))
                    }
                }
            case let .deleteSuccess(index):
                state.transactions.remove(at: index)
                return .none
            case let .deleteFailed(message):
                state.errorMessage = message
                return .none
            case let .searchTextChanged(newString):
                guard newString != state.searchString else { return .none }
                state.searchString = newString
                return .none
                
            case let .sortOptionChanged(option):
                state.sortOption = option
                return .none
            }
        }
        .ifLet(\.editorState, action: \.editor) {
            AddTransactionReducer()
        }
    }
}

// MARK: - TimeFrame Extension
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
