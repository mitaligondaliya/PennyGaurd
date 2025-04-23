//
//  Transaction.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import SwiftData

@Model
class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var notes: String?
    var type: CategoryType
    var category: Category

    init(id: UUID = UUID(), title: String, amount: Double, date: Date = .now, notes: String? = nil, category: Category, type: CategoryType) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.notes = notes
        self.category = category
        self.type = category.type
    }
}

enum TimeFrame: String, CaseIterable, Identifiable, Equatable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"

    var id: String { rawValue }
}
