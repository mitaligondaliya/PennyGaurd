//
//  RootView.swift
//  PennyGaurd
//
//  Created by Mitali Gondaliya on 02/05/25.
//

import SwiftData
import SwiftUI
import ComposableArchitecture

struct AppRootView: View {
    @Dependency(\.databaseService) var databaseService

    let store: StoreOf<AppReducer>

    var body: some View {
        if let modelContext = try? databaseService.context() {
            AppTabView(store: store)
                .modelContext(modelContext)
        } else {
            Text("Failed to load ModelContext.")
        }
    }
}
