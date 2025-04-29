//
//  AppReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import ComposableArchitecture

struct AppReducer: Reducer {
    struct State {
        var selectedTab: Tab = .dashboard
        var dashboard = TransactionReducer.State()
        var transactions = TransactionReducer.State()
    }

    @CasePathable
    enum Action {
        case dashboard(TransactionReducer.Action)
        case transactions(TransactionReducer.Action)
        case selectTab(Tab)
    }

    enum Tab: Hashable {
        case dashboard
        case transactions
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.dashboard, action: \.dashboard) {
            TransactionReducer()
        }

        Scope(state: \.transactions, action: \.transactions) {
            TransactionReducer()
        }

        Reduce { state, action in
            print("📬 AppReducer received action: \(action)")
            switch action {
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none
            case .dashboard, .transactions:
                return .none
            }
        }
    }
}
