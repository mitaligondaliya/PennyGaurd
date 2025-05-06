//
//  TransactionReducerTests.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 06/05/25.
//

 import Testing
 import Foundation
 import ComposableArchitecture

 @testable import PennyGaurd

 struct TransactionReducerTests {
    
    @Test
    func testFetchTransactionsLoadsData() async throws {
        // MARK: - Setup fake transactions
        let testTransaction = Transaction(
            title: "Groceries",
            amount: 100,
            date: .now,
            notes: "Weekly",
            category: .food,
            type: .expense
        )
        
        var testDB = TransactionDatabase.testValue
        testDB.fetchAll = {
            [testTransaction] // returns your fake transaction
        }
        
        // MARK: - Setup Store
        let store = await TestStore(initialState: TransactionReducer.State()) {
            TransactionReducer()
        } withDependencies: {
            $0.swiftData = testDB
        }
        
        // MARK: - Trigger fetch and expect loaded state
        await store.send(.loadTransactions)
        await store.receive(.transactionsLoadedSuccess([testTransaction])) {
            $0.transactions = [testTransaction]
        }
        
        await #expect(store.state.transactions.count == 1)
        await #expect(store.state.transactions.first?.title == "Groceries")
    }
    
    @Test
    func testFetchTransactionsFailure() async throws {
        // MARK: - Arrange
        let errorMessage = "Fetch failed"
        
        var testDB = TransactionDatabase.testValue
        testDB.fetchAll = {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        
        // MARK: - Setup Store
        let store = await TestStore(
            initialState: TransactionReducer.State()
        ) {
            TransactionReducer()
        } withDependencies: {
            $0.swiftData = testDB
        }
        
        // MARK: - Act
        await store.send(.loadTransactions)
        
        // MARK: - Assert
        await store.receive(.transactionsLoadedFailure(errorMessage)) {
            $0.errorMessage = errorMessage
        }
    }
    
    @Test
    func testDeleteTransaction() async throws {
        // MARK: - Arrange
        let transactionID = UUID()
        var deletedID: UUID?
        
        let transaction = Transaction(
            id: transactionID,
            title: "Sample",
            amount: 20,
            date: .now,
            notes: "Test",
            category: .food,
            type: .expense
        )
        
        var testDB = TransactionDatabase.testValue
        testDB.deleteByID = { id in
            deletedID = id
        }
        
        // MARK: - Setup Store
        let store = await TestStore(
            initialState: TransactionReducer.State(
                transactions: [transaction],
                errorMessage: ""
            )
        ) {
            TransactionReducer()
        } withDependencies: {
            $0.swiftData = testDB
        }
        
        // MARK: - Act
        await store.send(.delete(IndexSet(integer: 0)))
        
        // MARK: - Assert
        await store.receive(.deleteSuccess(index: 0)) {
            $0.transactions = []
        }
        
        #expect(deletedID == transactionID)
    }
    
    @Test
    func testDeleteTransactionFailure() async throws {
        // MARK: - Arrange
        let transactionID = UUID()
        let errorMessage = "Delete failed"
        
        let transaction = Transaction(
            id: transactionID,
            title: "Sample",
            amount: 20,
            date: .now,
            notes: "Test",
            category: .food,
            type: .expense
        )
        
        var testDB = TransactionDatabase.testValue
        testDB.deleteByID = { _ in
            throw NSError(domain: "Test", code: 1, userInfo: nil)
        }
        
        // MARK: - Setup Store
        let store = await TestStore(
            initialState: TransactionReducer.State(
                transactions: [transaction],
                errorMessage: ""
            )
        ) {
            TransactionReducer()
        } withDependencies: {
            $0.swiftData = testDB
        }
        
        // MARK: - Act
        await store.send(.delete(IndexSet(integer: 0)))
        
        // MARK: - Assert
        await store.receive(.deleteFailed(errorMessage)) {
            $0.errorMessage = errorMessage
        }
    }
 }
