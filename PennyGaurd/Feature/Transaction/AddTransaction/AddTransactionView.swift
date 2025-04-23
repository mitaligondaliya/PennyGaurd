//
//  AddTransactionView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import ComposableArchitecture

struct AddTransactionView: View {
    let store: StoreOf<AddTransactionReducer>

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    Section {
                        VStack {
                            TextField("Title", text: viewStore.binding(get: \.title, send: AddTransactionReducer.Action.titleChanged))
                                .autocapitalization(.sentences)
                            HStack {
                                Text("$")
                                    .font(.title)
                                    .foregroundStyle(.secondary)

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

                    Section {
                        Picker(selection: viewStore.binding(get: \.type, send: AddTransactionReducer.Action.typeChanged), label: Text("Type")) {
                            ForEach(CategoryType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Picker(selection: viewStore.binding(get: \.selectedCategory, send: AddTransactionReducer.Action.categorySelected), label: Text("Category")) {
                            ForEach(Category.allCases.filter { $0.type == viewStore.type }, id: \.self) { category in
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 10, height: 10)
                                    Text(category.displayName).tag(category)
                                }
                            }
                        }
                        
                        DatePicker("Date", selection: viewStore.binding(
                            get: \.date,
                            send: AddTransactionReducer.Action.dateChanged
                        ))
                    }
                    // MARK: - Notes
                    Section("Notes (Optional)") {
                        TextEditor(text: viewStore.binding(
                            get: \.notes,
                            send: AddTransactionReducer.Action.notesChanged
                        ))
                        .frame(minHeight: 100)
                    }
                }
                .navigationTitle(viewStore.isEditing ? "Edit Transaction" : "Add Transaction")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewStore.send(.cancelTapped)
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewStore.send(.saveTapped)
                        }
                        .disabled(viewStore.title.isEmpty || viewStore.amount <= 0)
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView(
        store: Store(initialState: AddTransactionReducer.State()) {
            AddTransactionReducer()
        }
    )
}
