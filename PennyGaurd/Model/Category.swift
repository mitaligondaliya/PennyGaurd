//
//  Category.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - CategoryType Enum
enum TransactionType: String, Codable, Equatable, CaseIterable {
    case income, expense
    
    var id: String { self.rawValue }
}

// MARK: - Category Enum
enum CategoryType: String, CaseIterable, Identifiable, Equatable, Codable {
    case salary
    case interest
    case rental
    case business
    case food
    case travel
    case entertainment
    case shopping
    case healthcare
    case other

    // MARK: - ID for Identifiable Protocol
    var id: String { rawValue }

    // MARK: - Display Name for Category
    var displayName: String {
        switch self {
        case .salary: return "Salary"
        case .interest: return "Interest"
        case .rental: return "Rental"
        case .business: return "Business"
        case .food: return "Food"
        case .travel: return "Travel"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .healthcare: return "Healthcare"
        case .other: return "Other"
        }
    }

    // MARK: - Color for Category
    var color: Color {
        switch self {
        case .salary: return .green
        case .interest: return .yellow
        case .rental: return .teal
        case .business: return .blue
        case .food: return .orange
        case .travel: return .purple
        case .entertainment: return .pink
        case .shopping: return .red
        case .healthcare: return .mint
        case .other: return .indigo
        }
    }

    // MARK: - Category Type (Income/Expense)
    var type: TransactionType {
        switch self {
        case .salary, .business, .rental, .interest:
            return .income
        default:
            return .expense
        }
    }
}
