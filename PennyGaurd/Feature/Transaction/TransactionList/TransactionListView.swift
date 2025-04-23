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
                        VStack(alignment: .leading) {
                            HStack {
                                Text(transaction.title)
                                Spacer()
                                Text("\(transaction.amount, specifier: "%.2f")")
                                    .foregroundColor(transaction.type == .income ? .green : .red)
                            }
                            Text(transaction.category.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            viewStore.send(.transactionTapped(transaction))
                        }
                    }
                    .onDelete { viewStore.send(.delete($0)) }
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
                .sheet(isPresented: viewStore.binding(get: \.isPresentingSheet, send: .sheetDismissed)) {
                    IfLetStore(
                        store.scope(state: \.editorState, action: TransactionListReducer.Action.editor),
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
