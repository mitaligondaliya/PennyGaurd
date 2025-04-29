//
//  TransactionListView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - TransactionList View
struct TransactionListView: View {
    let store: StoreOf<TransactionReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    // MARK: - Sort Options Section
                    sortOptionsSection(viewStore: viewStore)
                    
                    // MARK: - Transaction Rows
                    ForEach(viewStore.filteredTransactions, id: \.id) { transaction in
                        TransactionRowView(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                swipeActions(for: transaction, viewStore: viewStore)
                            }
                    }
                }
                .searchable(
                    text: viewStore.binding(
                        get: \.searchString,
                        send: TransactionReducer.Action.searchTextChanged
                    )
                )
                .navigationTitle("All Transactions")
                
                // MARK: - Toolbar Add Button
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.addButtonTapped) }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                // MARK: - Load Data on Appear
                .onAppear {
                    viewStore.send(.loadTransactions)
                }

                // MARK: - Sheet for Add/Edit Transaction
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.isPresentingSheet,
                        send: .sheetDismissed
                    )
                ) {
                    IfLetStore(
                        store.scope(state: \.editorState, action: \.editor),
                        then: AddTransactionView.init(store:)
                    )
                }
            }
        }
    }

    // MARK: - Sort Option Pills Section
    @ViewBuilder
    private func sortOptionsSection(viewStore: ViewStoreOf<TransactionReducer>) -> some View {
        Section(header: Text("Sort By")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            viewStore.send(.sortOptionChanged(option))
                        }) {
                            Text(option.displayName)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    viewStore.sortOption == option
                                    ? Color.accentColor
                                    : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(
                                    viewStore.sortOption == option
                                    ? .white
                                    : .primary
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Swipe Actions (Delete & Edit)
    @ViewBuilder
    private func swipeActions(for transaction: Transaction, viewStore: ViewStoreOf<TransactionReducer>) -> some View {
        if let index = viewStore.transactions.firstIndex(where: { $0.id == transaction.id }) {
            Button(role: .destructive) {
                viewStore.send(.delete(IndexSet(integer: index)))
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                viewStore.send(.transactionTapped(transaction))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

// MARK: - TransactionRow View
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // MARK: - Title and Amount
            HStack {
                Text(transaction.title)
                    .font(.body)
                Spacer()
                Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .foregroundColor(transaction.type == .income ? .green : .red)
            }

            // MARK: - Category and Date
            HStack {
                Text(transaction.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    TransactionListView(
        store: Store(initialState: TransactionReducer.State()) {
            TransactionReducer()
        }
    )
    .modelContainer(for: [Transaction.self])
}

#Preview("Transaction Row") {
    TransactionRowView(transaction: Transaction(
        id: UUID(),
        title: "Groceries",
        amount: 52.49,
        date: Date(),
        notes: "Weekly shopping",
        category: .food,
        type: .expense
    ))
    .padding()
}
