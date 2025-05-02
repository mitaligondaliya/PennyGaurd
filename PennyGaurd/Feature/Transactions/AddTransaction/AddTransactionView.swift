//
//  AddTransactionView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - AddTransaction View
struct AddTransactionView: View {
    let store: StoreOf<AddTransactionReducer>

    @Environment(\.dismiss) private var dismiss

    // MARK: - Helper Functions
    private func binding<T>(
        get: @escaping (AddTransactionReducer.State) -> T,
        send: @escaping (T) -> AddTransactionReducer.Action
    ) -> Binding<T> {
        // Returns a Binding that gets and sets values from the store
        return Binding(
            get: { get(store.state) },
            set: { store.send(send($0)) }
        )
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    // MARK: - Title & Amount Section
                    Section {
                        VStack {
                            // Title TextField
                            TextField("Title", text: viewStore.binding(get: \.title, send: AddTransactionReducer.Action.titleChanged))
                                .autocapitalization(.sentences)

                            HStack {
                                Text("$")
                                    .font(.title)
                                    .foregroundStyle(.secondary)

                                // Amount TextField
                                TextField(
                                    "",
                                    value: viewStore.binding(
                                        get: \.amount,
                                        send: AddTransactionReducer.Action.amountChanged
                                    ),
                                    format: .number
                                )
                                .font(.system(size: 36, weight: .bold))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 12)
                        }
                    }

                    // MARK: - Type Selection Section
                    Section {
                        // Picker for selecting type (Income/Expense)
                        Picker(selection: viewStore.binding(get: \.type, send: AddTransactionReducer.Action.typeChanged), label: Text("Type")) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: - Category & Date Section
                    Section {
                        // Picker for selecting category
                        Picker(
                            selection: viewStore.binding(
                                get: \.selectedCategory,
                                send: AddTransactionReducer.Action.categorySelected
                            ),
                            label: Text("Category")
                        ) {
                            ForEach(CategoryType.allCases.filter { $0.type == viewStore.type }, id: \.self) { category in
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 10, height: 10)
                                    Text(category.displayName)
                                }
                                .tag(category) // ✅ Apply tag to the full row
                            }
                        }

                        // DatePicker for selecting transaction date
                        DatePicker("Date", selection: viewStore.binding(
                            get: \.date,
                            send: AddTransactionReducer.Action.dateChanged
                        ))
                    }

                    // MARK: - Notes Section
                    Section("Notes (Optional)") {
                        // TextEditor for optional notes
                        TextEditor(text: viewStore.binding(
                            get: \.notes,
                            send: AddTransactionReducer.Action.notesChanged
                        ))
                        .frame(minHeight: 100)
                    }
                }
                .navigationTitle(viewStore.isEditing ? "Edit Transaction" : "Add Transaction")
                .toolbar {
                    // MARK: - Cancel & Save Toolbar Items
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewStore.send(.cancelTapped)  // Dismiss view on cancel
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewStore.send(.saveTapped)  // Save transaction on tap
                        }
                        .disabled(viewStore.title.isEmpty || viewStore.amount <= 0) // Disable save if title or amount is invalid
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddTransactionView(
        store: Store(initialState: AddTransactionReducer.State()) {
            AddTransactionReducer()
        }
    )
}
