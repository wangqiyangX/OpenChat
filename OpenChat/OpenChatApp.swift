//
// OpenChatApp.swift
// OpenChat
//
// Copyright © 2025 wangqiyangX.
// All Rights Reserved.
//

import SwiftData
import SwiftUI

@main
struct OpenChatApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var conversationManager = ConversationManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ChatView()
            }
            .environment(conversationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
