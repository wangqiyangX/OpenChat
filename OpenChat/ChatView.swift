//
// ChatView.swift
// OpenChat
//
// Copyright © 2025 wangqiyangX.
// All Rights Reserved.
//

import OpenAI
import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    var content: String
    var role: ChatQuery.ChatCompletionMessageParam.Role
    var createdAt: Date = .now
}

@Observable
class ViewModel {
    var messages: [Message] = [
        Message(content: "How is the weather today?", role: .user)
    ]
}

struct ChatView: View {
    @State private var inputText: String = ""
    @State private var viewModel = ViewModel()
    @State private var showHistorySheet: Bool = false

    enum Field: Hashable {
        case inputTextField
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.messages) { message in
                    Text(message.content)
                }
            }
            #if os(iOS)
                .listRowSpacing(20)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle("OpenChat")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {

                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("History", systemImage: "list.bullet") {
                        withAnimation {
                            showHistorySheet.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
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
                        Image(systemName: "plus")
                    }
                }
                ToolbarSpacer(.fixed, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    TextField("Ask anything", text: $inputText, axis: .vertical)
                        .focused($focusedField, equals: .inputTextField)
                }
                ToolbarSpacer(.fixed, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {

                    } label: {
                        Image(systemName: "waveform")
                    }
                }
            }
            .sheet(isPresented: $showHistorySheet) {
                List {

                }
            }
            .onAppear {
                focusedField = .inputTextField
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
