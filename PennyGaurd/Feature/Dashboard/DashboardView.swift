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
                            action: \.editor
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
            
            Divider()

            if !viewStore.expensesByCategory.isEmpty {
                ForEach(viewStore.expensesByCategory.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                    VStack(alignment: .leading, spacing: 10) {
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

    private func recentTransactions(_ viewStore: ViewStore<DashboardReducer.State, DashboardReducer.Action>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
            }
            
            Divider()

            if !viewStore.filteredTransactions.isEmpty {
                ForEach(viewStore.filteredTransactions.prefix(5)) { transaction in
                    
                    TransactionRow(transaction: transaction)

                    if transaction.id != viewStore.filteredTransactions.prefix(5).last?.id {
                        Divider()
                    }
                }
            } else {
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
    
    let modelContainer: ModelContainer = {
            do {
                let schema = Schema([Transaction.self])
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }()

        let modelContext = modelContainer.mainContext
    DashboardView(
        store: Store(initialState: DashboardReducer.State()) {
            DashboardReducer()
        }
    )
    .environment(\.modelContext, modelContext)
}

