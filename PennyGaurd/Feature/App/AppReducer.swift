//
//  AppReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import ComposableArchitecture

// MARK: - AppReducer

struct AppReducer: Reducer {
    
    // MARK: - State

    struct State {
        var selectedTab: Tab = .dashboard
        var dashboard = TransactionReducer.State()     // State for the Dashboard tab
        var transactions = TransactionReducer.State()  // State for the Transactions tab
    }

    // MARK: - Action

    @CasePathable
    enum Action {
        case dashboard(TransactionReducer.Action)      // Forward action to Dashboard reducer
        case transactions(TransactionReducer.Action)   // Forward action to Transactions reducer
        case selectTab(Tab)                            // Tab selection action
    }

    // MARK: - Tab Enum

    enum Tab: Hashable {
        case dashboard
        case transactions
    }

    // MARK: - Body

    var body: some ReducerOf<Self> {
        
        // Scope Dashboard state and actions to TransactionReducer
        Scope(state: \.dashboard, action: \.dashboard) {
            TransactionReducer()
        }

        // Scope Transactions state and actions to TransactionReducer
        Scope(state: \.transactions, action: \.transactions) {
            TransactionReducer()
        }

        // Reducer handling tab selection and general app-level logic
        Reduce { state, action in
            print("📬 AppReducer received action: \(action)")
            switch action {
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none
            case .dashboard, .transactions:
                return .none // Forwarded actions handled in respective scoped reducers
            }
        }
    }
}
