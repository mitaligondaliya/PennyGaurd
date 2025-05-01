//
//  DashboardView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

// MARK: - DashboardView
struct DashboardView: View {
    let store: StoreOf<TransactionReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary card showing balance, income, and expense
                        summaryCard(viewStore)

                        // Breakdown of expenses by category with progress bars
                        categoryBreakdown(viewStore)

                        // List of recent transactions
                        recentTransactions(viewStore)
                    }
                    .padding()
                }
                .navigationTitle("Dashboard")
                
                // Toolbar with time frame picker and add button
                .toolbar { toolbarContent(viewStore) }

                // Load transactions when view appears
                .onAppear {
                    viewStore.send(.loadTransactions)
                }

                // Sheet for adding/editing transaction
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.isPresentingSheet,
                        send: .sheetDismissed
                    )
                ) {
                    IfLetStore(
                        store.scope(
                            state: \.editorState,
                            action: \.editor
                        ),
                        then: AddTransactionView.init(store:)
                    )
                }
            }
        }
    }

    // MARK: - Summary Card
    private func summaryCard(_ viewStore: ViewStore<TransactionReducer.State, TransactionReducer.Action>) -> some View {
        VStack(spacing: 12) {
            // Display current balance
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

            // Show total income and total expense
            HStack {
                incomeExpenseView(title: "Income", amount: viewStore.totalIncome, color: .green)
                Spacer()
                incomeExpenseView(title: "Expenses", amount: viewStore.totalExpense, color: .red)
            }
        }
        .cardStyle()
    }

    // MARK: - Income/Expense Subview
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

    // MARK: - Category Breakdown Section
    private func categoryBreakdown(_ viewStore: ViewStore<TransactionReducer.State, TransactionReducer.Action>) -> some View {
        VStack(alignment: .leading) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.bottom, 5)

            Divider()

            if !viewStore.expensesByCategory.isEmpty {
                ForEach(viewStore.expensesByCategory.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                    VStack(alignment: .leading, spacing: 10) {
                        // Category name and amount
                        HStack {
                            Text(category.displayName)
                            Spacer()
                            Text("$\(amount, specifier: "%.2f")")
                                .fontWeight(.medium)
                        }

                        // Progress bar based on total expenses
                        ProgressView(value: min(max(amount, 0), viewStore.totalExpense), total: viewStore.totalExpense)
                            .tint(category.color)
                    }
                }
            } else {
                // Placeholder if no expense data
                PlaceholderView(
                    message: "No expense data for the selected period.",
                    addAction: {
                        viewStore.send(.addButtonTapped)
                    }
                )
            }
        }
        .cardStyle()
    }

    // MARK: - Recent Transactions Section
    private func recentTransactions(_ viewStore: ViewStore<TransactionReducer.State, TransactionReducer.Action>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
            }

            Divider()

            if !viewStore.filteredTransactions.isEmpty {
                ForEach(viewStore.filteredTransactions.prefix(5)) { transaction in
                    // Transaction row
                    TransactionRow(transaction: transaction)

                    // Divider between rows except the last one
                    if transaction.id != viewStore.filteredTransactions.prefix(5).last?.id {
                        Divider()
                    }
                }
            } else {
                // Placeholder if no transactions
                PlaceholderView(
                    message: "No transactions for the selected period.",
                    addAction: {
                        viewStore.send(.addButtonTapped)
                    }
                )
            }
        }
        .cardStyle()
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarContent(_ viewStore: ViewStore<TransactionReducer.State, TransactionReducer.Action>) -> some ToolbarContent {
        // Time Frame Picker (top leading)
        ToolbarItem(placement: .topBarLeading) {
            Picker("Time Frame", selection: viewStore.binding(
                get: \.timeFrame,
                send: TransactionReducer.Action.setTimeFrame
            )) {
                ForEach(TimeFrame.allCases) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(.menu)
        }

        // Add button (top trailing)
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
        store: Store(initialState: TransactionReducer.State()) {
            TransactionReducer()
        }
    )
    .modelContainer(for: [Transaction.self])
}
