//
//  AddTransactionReducer.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 05/05/25.
//

import Testing
import SwiftData
import Foundation
import ComposableArchitecture

@testable import PennyGaurd

struct AddTransactionReducerTests {
    
    @Test func testSaveTappedAddsNewTransaction() async throws {
        // Prepare mock date and capture variable
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var savedTransaction: Transaction?
        
        // Create test dependency with overridden `add` method
        var testDB = DatabaseClient.testValue
        testDB.add = { transaction in
            savedTransaction = transaction
        }
        
        // Initialize the TestStore with AddTransactionReducer
        let store = await TestStore(initialState: AddTransactionReducer.State()) {
            AddTransactionReducer()
        } withDependencies: {
            $0.swiftData = testDB
            $0.date = .constant(now)
        }
        
        // Send user input actions to update the state
        await store.send(.titleChanged("Travel")) {
            $0.title = "Travel"
        }
        
        await store.send(.amountChanged(50)) {
            $0.amount = 50
        }
        
        await store.send(.notesChanged("Test")) {
            $0.notes = "Test"
        }
        
        // Important: Send type change **before** selecting category,
        // because type change may override selectedCategory.
        await store.send(.typeChanged(.expense)) {
            $0.type = .expense
            if let firstCategory = CategoryType.allCases.first(where: { $0.type == .expense }) {
                $0.selectedCategory = firstCategory
            }
        }
        
        await store.send(.categorySelected(.travel)) {
            $0.selectedCategory = .travel
        }
        
        // Trigger save action
        await store.send(.saveTapped)
        
        // Expect completion action
        await store.receive(.saveCompleted)
        
        // Assert the transaction was saved with correct values
        #expect(savedTransaction?.title == "Travel")
        #expect(savedTransaction?.amount == 50)
        #expect(savedTransaction?.notes == "Test")
        #expect(savedTransaction?.type == .expense)
        #expect(savedTransaction?.category == .travel)
    }
    
    @Test func testSaveTappedEditsTransaction() async throws {
        // Create an existing transaction
        let existingTransaction = Transaction(
            title: "Old Title",
            amount: 50,
            date: Date(),
            notes: "Old Notes",
            category: .travel,
            type: .expense
        )
        
        var savedTransaction: Transaction?
        
        // Create a test version of the database to override the `add` and `update` methods
        var testDB = DatabaseClient.testValue
        testDB.update = { transaction in
            savedTransaction = transaction // Capture the saved transaction
        }
        
        // Initialize the store with existing transaction state
        let store = TestStore(initialState: AddTransactionReducer.State(existing: existingTransaction)) {
            AddTransactionReducer()
        } withDependencies: {
            $0.swiftData = testDB
        }
        
        // Change the transaction's details
        await store.send(.titleChanged("Rent")) {
            $0.title = "Rent"
        }
        await store.send(.amountChanged(100)) {
            $0.amount = 100
        }
        await store.send(.notesChanged("Test")) {
            $0.notes = "Test"
        }
        await store.send(.typeChanged(.income)) {
            $0.type = .income
            $0.selectedCategory = .salary
        }
        await store.send(.categorySelected(.rental)) {
            $0.selectedCategory = .rental
        }
        // Trigger save action
        await store.send(.saveTapped)
        
        // Expect save completion
        await store.receive(.saveCompleted)
        
        // Verify that the transaction was updated
        #expect(savedTransaction?.title == "Rent")
        #expect(savedTransaction?.amount == 100)
        #expect(savedTransaction?.notes == "Test")
        #expect(savedTransaction?.category == .rental)
        #expect(savedTransaction?.type == .income)
    }
}
