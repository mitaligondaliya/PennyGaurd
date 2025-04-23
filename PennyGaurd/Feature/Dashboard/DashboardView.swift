//
//  DashboardView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - DashboardView
struct DashboardView: View {
    let store: StoreOf<DashboardReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard(viewStore)
                        categoryBreakdown(viewStore)
                        recentTransactions(viewStore)
                    }
                    .padding()
                }
                .navigationTitle("Dashboard")
                .toolbar { toolbarContent(viewStore) }
                .onAppear {
                    viewStore.send(.loadTransactions)
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.isPresentingSheet,
                        send: .sheetDismissed
                    )
                ) {
                    IfLetStore(
                        store.scope(
                            state: \.editorState,
                            action: DashboardReducer.Action.editor
                        ),
                        then: AddTransactionView.init(store:)
                    )
                }
            }
        }
    }

    // MARK: - View Sections

    private func summaryCard(_ viewStore: ViewStore<DashboardReducer.State, DashboardReducer.Action>) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(viewStore.balance, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
            }

            Divider()

            HStack {
                incomeExpenseView(title: "Income", amount: viewStore.totalIncome, color: .green)
                Spacer()
                incomeExpenseView(title: "Expenses", amount: viewStore.totalExpense, color: .red)
            }
        }
        .cardStyle()
    }

    private func incomeExpenseView(title: String, amount: Double, color: Color) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("$\(amount, specifier: "%.2f")")
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }

    private func categoryBreakdown(_ viewStore: ViewStore<DashboardReducer.State, DashboardReducer.Action>) -> some View {
        VStack(alignment: .leading) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.bottom, 5)

            if !viewStore.expensesByCategory.isEmpty {
                ForEach(viewStore.expensesByCategory.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(category.displayName)
                            Spacer()
                            Text("$\(amount, specifier: "%.2f")")
                                .fontWeight(.medium)
                        }

                        ProgressView(value: amount, total: viewStore.totalExpense)
                            .tint(category.color)
                    }
                }
            } else {
                Text("No expense data for selected period")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .cardStyle()
    }

    private func recentTransactions(_ viewStore: ViewStore<DashboardReducer.State, DashboardReducer.Action>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
            }
            .padding(.bottom, 5)

            if !viewStore.filteredTransactions.isEmpty {
                ForEach(viewStore.filteredTransactions.prefix(5)) { transaction in
                    TransactionRow(transaction: transaction)

                    if transaction.id != viewStore.filteredTransactions.prefix(5).last?.id {
                        Divider()
                    }
                }
            } else {
                Text("No transactions for selected period")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .cardStyle()
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarContent(_ viewStore: ViewStore<DashboardReducer.State, DashboardReducer.Action>) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Picker("Time Frame", selection: viewStore.binding(
                get: \.timeFrame,
                send: DashboardReducer.Action.setTimeFrame
            )) {
                ForEach(TimeFrame.allCases) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(.menu)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewStore.send(.addButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView(
        store: Store(initialState: DashboardReducer.State()) {
            DashboardReducer()
        }
    )
}
