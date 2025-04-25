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
        var dashboard = DashboardReducer.State()
        var transactions = TransactionListReducer.State()
    }
    
    @CasePathable
    enum Action {
        case dashboard(DashboardReducer.Action)
        case transactions(TransactionListReducer.Action)
        case selectTab(Tab)
    }

    enum Tab: Hashable {
        case dashboard
        case transactions
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.dashboard, action: \.dashboard) {
            DashboardReducer()
        }

        Scope(state: \.transactions, action: \.transactions) {
            TransactionListReducer()
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
