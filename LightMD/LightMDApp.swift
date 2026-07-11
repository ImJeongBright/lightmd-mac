import SwiftUI

private struct MarkdownViewModelFocusedKey: FocusedValueKey {
    typealias Value = MarkdownViewModel
}

extension FocusedValues {
    var markdownViewModel: MarkdownViewModel? {
        get { self[MarkdownViewModelFocusedKey.self] }
        set { self[MarkdownViewModelFocusedKey.self] = newValue }
    }
}

private struct WorkspaceViewModelFocusedKey: FocusedValueKey {
    typealias Value = WorkspaceViewModel
}

extension FocusedValues {
    var workspaceViewModel: WorkspaceViewModel? {
        get { self[WorkspaceViewModelFocusedKey.self] }
        set { self[WorkspaceViewModelFocusedKey.self] = newValue }
    }
}

@main
struct LightMDApp: App {
    var body: some Scene {
        WindowGroup("LightMD", id: "reader") {
            ContentView()
        }
        .commands {
            LightMDCommands()
        }

        WindowGroup("LightMD", for: DocumentWindowRequest.self) { request in
            ContentView(restoresLastSession: false, windowRequest: request.wrappedValue)
        }
    }
}

struct LightMDCommands: Commands {
    @FocusedValue(\.markdownViewModel) private var viewModel
    @FocusedValue(\.workspaceViewModel) private var workspaceViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window") {
                openWindow(value: DocumentWindowRequest())
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("Open...") {
                viewModel?.openWithPanel()
            }
            .keyboardShortcut("o", modifiers: [.command])
            .disabled(viewModel == nil)

            Button("Open Folder...") {
                workspaceViewModel?.openFolderWithPanel()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
            .disabled(workspaceViewModel == nil)
        }

        CommandGroup(replacing: .saveItem) {
            Button("Save") {
                viewModel?.save()
            }
            .keyboardShortcut("s", modifiers: [.command])
            .disabled(viewModel?.canSave != true)
        }

        CommandMenu("Mode") {
            Button(viewModel?.mode.toggleTitle ?? "Edit") {
                viewModel?.toggleMode()
            }
            .keyboardShortcut("e", modifiers: [.command])
            .disabled(viewModel?.document == nil)
        }

        CommandMenu("Navigation") {
            Button("Back") {
                NotificationCenter.default.post(name: .init("NavigateBack"), object: nil)
            }
            .keyboardShortcut("[", modifiers: [.command])

            Button("Forward") {
                NotificationCenter.default.post(name: .init("NavigateForward"), object: nil)
            }
            .keyboardShortcut("]", modifiers: [.command])

            Divider()

            Button("Back") {
                NotificationCenter.default.post(name: .init("NavigateBack"), object: nil)
            }
            .keyboardShortcut(.leftArrow, modifiers: [.command])

            Button("Forward") {
                NotificationCenter.default.post(name: .init("NavigateForward"), object: nil)
            }
            .keyboardShortcut(.rightArrow, modifiers: [.command])

            Button("Back") {
                NotificationCenter.default.post(name: .init("NavigateBack"), object: nil)
            }
            .keyboardShortcut(.leftArrow, modifiers: [.command, .option])

            Button("Forward") {
                NotificationCenter.default.post(name: .init("NavigateForward"), object: nil)
            }
            .keyboardShortcut(.rightArrow, modifiers: [.command, .option])
        }
    }
}
