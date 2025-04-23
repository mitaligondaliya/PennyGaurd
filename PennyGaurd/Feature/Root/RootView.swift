//
//  RootView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

//MARK: ContentView
struct RootView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        WithViewStore(self.store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(
                get: { $0 },
                send: AppReducer.Action.selectTab
            )) {
                DashboardView(
                    store: store.scope(
                        state: \.dashboard,  // Key path to the dashboard state
                        action: AppReducer.Action.dashboard  // Case key path to the dashboard action
                    )
                )
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie")
                }
                .tag(AppReducer.Tab.dashboard)

                TransactionListView(
                    store: store.scope(
                        state: \.transactions,
                        action: AppReducer.Action.transactions
                    )
                )
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
                .tag(AppReducer.Tab.transactions)
            }
        }
    }
}

#Preview {
    RootView(store: Store(initialState: AppReducer.State(), reducer: {
        AppReducer()
    }))
}
