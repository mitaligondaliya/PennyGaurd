//
//  RootView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - AppTabView

struct AppTabView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        WithViewStore(self.store, observe: \.selectedTab) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: { $0 },
                    send: AppReducer.Action.selectTab
                )
            ) {
                // MARK: - Dashboard Tab
                DashboardView(
                    store: store.scope(
                        state: \.dashboard,     // Scope to dashboard state
                        action: \.dashboard     // Scope to dashboard actions
                    )
                )
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie")
                }
                .tag(AppReducer.Tab.dashboard)

                // MARK: - Transactions Tab
                TransactionListView(
                    store: store.scope(
                        state: \.transactions,  // Scope to transactions state
                        action: \.transactions  // Scope to transactions actions
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

// MARK: - Preview

#Preview {
    AppTabView(
        store: Store(
            initialState: AppReducer.State(),
            reducer: {
                AppReducer()
            }
        )
    )
}
