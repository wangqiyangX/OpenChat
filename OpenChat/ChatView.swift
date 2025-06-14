//
// ChatView.swift
// OpenChat
//
// Copyright © 2025 wangqiyangX.
// All Rights Reserved.
//

import OpenAI
import SwiftUI

struct Message: Identifiable, Hashable {
    let id = UUID()
    var content: String
    var role: ChatQuery.ChatCompletionMessageParam.Role
    var createdAt: Date = .now
}

struct Conversation: Identifiable, Hashable {
    let id = UUID()
    var name: String = Date.now.formatted()
    var messages: [Message] = []
}

@Observable
class ConversationManager {
    var history: [Conversation] = []

    var selectedConversation: Conversation = Conversation()
}

struct MessageCellView: View {
    let message: Message

    @State private var showCreatedTime: Bool = false

    var body: some View {
        Section {
            Text(message.content)
                .textSelection(.enabled)
                .foregroundStyle(message.role == .user ? .gray : .primary)
                .onTapGesture {
                    showCreatedTime.toggle()
                }
        } header: {

        } footer: {
            Text(message.createdAt.formatted())
        }
    }
}

struct ChatView: View {
    @Environment(ConversationManager.self) private var conversationManager

    @State private var inputText: String = ""
    @State private var showHistorySheet: Bool = false
    @State private var isExpandedInputTextField: Bool = false
    @State private var currentConversation = Conversation()
    @State private var selectedChatType: ChatType = .search

    enum Field: Hashable {
        case inputTextField
    }

    enum ChatType: String, CaseIterable, Identifiable {
        case search
        case image

        var id: Self { self }

        var name: String {
            switch self {
            case .search:
                "Search the web"
            case .image:
                "Crate an image"
            }
        }

        var icon: String {
            switch self {
            case .search:
                "globe"
            case .image:
                "scribble"
            }
        }
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        List {
            ForEach(conversationManager.selectedConversation.messages) {
                message in
                MessageCellView(message: message)
            }
        }
        #if os(iOS)
            .listRowSpacing(20)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle("OpenChat")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {

                    } label: {
                        Label("Files", systemImage: "folder")
                    }
                    Button {

                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                    Button {

                    } label: {
                        Label("Photo", systemImage: "photo")
                    }
                } label: {
                    Image(systemName: "paperclip")
                }
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Type", selection: $selectedChatType) {
                        ForEach(ChatType.allCases) { type in
                            Label(type.name, systemImage: type.icon)
                        }
                    }
                    .pickerStyle(.menu)
                } label: {
                    Image(systemName: "ellipsis")
                }
            }

            ToolbarItemGroup(placement: .topBarLeading) {
                Button("History", systemImage: "list.bullet") {
                    withAnimation {
                        showHistorySheet.toggle()
                    }
                }
            }

            ToolbarItem(placement: .bottomBar) {
                TextField("Ask anything you want to know", text: $inputText)
                    .controlSize(.extraLarge)
                    .padding(.horizontal)
                    .onSubmit {
                        withAnimation {
                            if !inputText.isEmpty {
                                let message = Message(
                                    content: inputText,
                                    role: .user
                                )
                                conversationManager.selectedConversation.messages.append(message)
                                inputText = ""
                            }
                        }
                    }
            }
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                if !conversationManager.selectedConversation.messages.isEmpty {
                    Button {
                        conversationManager.history.append(
                            conversationManager.selectedConversation
                        )
                        conversationManager.selectedConversation = Conversation()
                    } label: {
                        Label("Add", systemImage: "square.and.pencil")
                    }
                }
            }
        }
        //            .safeAreaInset(edge: .bottom) {
        //                GlassEffectContainer {
        //                    HStack(alignment: .bottom) {
        //                        Menu {
        //                            Button {
        //
        //                            } label: {
        //                                Label("Files", systemImage: "folder")
        //                            }
        //                            Button {
        //
        //                            } label: {
        //                                Label("Camera", systemImage: "camera")
        //                            }
        //                            Button {
        //
        //                            } label: {
        //                                Label("Photo", systemImage: "photo")
        //                            }
        //                        } label: {
        //                            Image(systemName: "plus")
        //                                .frame(width: 20, height: 20)
        //                                .bold()
        //                                .padding()
        //                                .glassEffect(.regular.interactive())
        //                        }
        //                        .buttonStyle(.plain)
        //
        //                        TextField(
        //                            "",
        //                            text: $inputText,
        //                            prompt: Text("Ask anything")
        //                        )
        //                        .padding()
        //                        .glassEffect(.regular.interactive())
        //                        Button {
        //
        //                        } label: {
        //                            Image(systemName: "waveform")
        //                                .frame(width: 20, height: 20)
        //                                .bold()
        //                                .padding()
        //                                .glassEffect(.regular.interactive())
        //                        }
        //                        .buttonStyle(.plain)
        //                    }
        //                    .padding()
        //                }
        //            }
        .sheet(isPresented: $showHistorySheet) {
            HistoryListView()
        }
        .sheet(isPresented: $isExpandedInputTextField) {
            NavigationStack {
                List {
                    TextEditor(text: $inputText)
                        .frame(minHeight: 200)
                }
                .toolbar {
                    Button {
                        withAnimation {
                            isExpandedInputTextField.toggle()
                        }
                    } label: {
                        Image(
                            systemName:
                                "arrow.up.right.and.arrow.down.left"
                        )
                    }
                }
            }
        }
        .onAppear {
            focusedField = .inputTextField
        }
    }
}

struct HistoryListView: View {
    @State private var searchHistory: String = ""
    @Environment(ConversationManager.self) private var conversationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(conversationManager.history) { item in
                    Button {
                        conversationManager.selectedConversation = item
                        dismiss()
                    } label: {
                        Text(item.name)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchHistory)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
    .environment(ConversationManager())
}
