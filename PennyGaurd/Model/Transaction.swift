//
//  Transaction.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import SwiftData

// MARK: - Transaction Model
@Model
class Transaction: Identifiable, Equatable {
    // MARK: - Attributes
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var notes: String?
    var type: TransactionType
    var category: CategoryType

    // MARK: - Initializer
    init(id: UUID = UUID(), title: String, amount: Double, date: Date = .now, notes: String? = nil, category: CategoryType, type: TransactionType) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.notes = notes
        self.category = category
        self.type = type
    }
}

// MARK: - TimeFrame Enum
enum TimeFrame: String, CaseIterable, Identifiable, Equatable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"

    // MARK: - ID for Identifiable Protocol
    var id: String { rawValue }
}

// MARK: - Mock Data
extension Transaction {
    static let sampleTransactions = [
        Transaction(title: "Travel", amount: 50, date: .now, category: .travel, type: .expense),
        Transaction(title: "Salary", amount: 2000, date: .now, category: .salary, type: .income),
        Transaction(title: "Restaurant", amount: 50, date: .now, category: .food, type: .expense),
        Transaction(title: "Bonus", amount: 300, date: .now, category: .business, type: .income),
        Transaction(title: "Rent", amount: 1000, date: .now, category: .rental, type: .expense)
    ]
}
