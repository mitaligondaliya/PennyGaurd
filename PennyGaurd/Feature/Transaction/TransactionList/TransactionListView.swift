//
//  TransactionListView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

struct TransactionListView: View {
    let store: StoreOf<TransactionListReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.transactions, id: \.id) { transaction in
                        TransactionRowView(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                let deleteButton = Button(role: .destructive) {
                                    if let index = viewStore.transactions.firstIndex(where: { $0.id == transaction.id }) {
                                        viewStore.send(.delete(IndexSet(integer: index)))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                let editButton = Button {
                                    viewStore.send(.transactionTapped(transaction))
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                    .tint(.blue)

                                deleteButton
                                editButton
                            }
                    }
                }
                .navigationTitle("All Transactions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
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
}

#Preview {
    TransactionListView(
        store: Store(initialState: TransactionListReducer.State()) {
            TransactionListReducer()
        }
    )
    .modelContainer(for: [Transaction.self])
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(transaction.title)
                    .font(.body)
                Spacer()
                Text("\(transaction.amount, specifier: "%.2f")")
                    .foregroundColor(transaction.type == .income ? .green : .red)
            }
            HStack {
                Text(transaction.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()

                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
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
