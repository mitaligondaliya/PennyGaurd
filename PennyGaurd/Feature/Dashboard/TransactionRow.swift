//
//  TransactionRow.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 22/04/25.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

// MARK: - Transaction Row View
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Text(transaction.category.displayName)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.type == .expense ? "-$\(transaction.amount, specifier: "%.2f")" : "+$\(transaction.amount, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.type == .expense ? .red : .green)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionRow(transaction: .init(title: "", amount: 0.0, category: .business, type: .income))
}
