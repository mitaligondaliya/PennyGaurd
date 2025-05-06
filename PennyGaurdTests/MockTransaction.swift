//
//  MockTransaction.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 06/05/25.
//

import Foundation
@testable import PennyGaurd

struct MockTransaction: Equatable {
    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let notes: String
    let category: CategoryType
    let type: TransactionType
}

extension MockTransaction {
    static func sample(
        id: UUID = UUID(),
        title: String = "Sample",
        amount: Double = 100,
        date: Date = .now,
        notes: String = "Test",
        category: CategoryType = .food,
        type: TransactionType = .expense
    ) -> MockTransaction {
        .init(id: id, title: title, amount: amount, date: date, notes: notes, category: category, type: type)
    }
}

extension Transaction {
    static func fromMock(_ mock: MockTransaction) -> Transaction {
        let transaction = Transaction(
            title: mock.title,
            amount: mock.amount,
            date: mock.date,
            notes: mock.notes,
            category: mock.category,
            type: mock.type
        )
        transaction.id = mock.id
        return transaction
    }
}
