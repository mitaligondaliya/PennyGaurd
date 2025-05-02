//
//  PennyGaurdApp.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 18/04/25.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct PennyGaurdApp: App {

    // Create the ModelContainer for Transaction model
//    let modelContainer: ModelContainer
//    let store = Store(initialState: AppReducer.State()) {
//        AppReducer()
//       }
//
//       init() {
//           do {
//               // Create the ModelContainer for the 'Transaction' model
//               modelContainer = try ModelContainer(for: Transaction.self)
//           } catch {
//               fatalError("Could not create model container: \(error)")
//           }
//       }
//    @Dependency(\.databaseService) var databaseService
//    var modelContext: ModelContext {
//        guard let modelContext = try? self.databaseService.context() else {
//            fatalError("Could not find modelcontext")
//        }
//        return modelContext
//    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                store: Store(
                    initialState: AppReducer.State(),
                    reducer: { AppReducer() }
                )
            )
        }
    }
}
