import Foundation
import Combine
import AppKit

@MainActor
final class WorkspaceViewModel: ObservableObject {
    @Published var tabs: [WorkspaceTab] = []
    @Published var selectedTabID: UUID?
    
    private let savedTabsKey = "LightMDWorkspaceTabs"
    private let savedSelectedTabKey = "LightMDSelectedTabID"
    
    init() {
        restoreSession()
    }
    
    var selectedTab: WorkspaceTab? {
        guard let id = selectedTabID else { return nil }
        return tabs.first { $0.id == id }
    }
    
    func openFolderWithPanel() {
        let panel = NSOpenPanel()
        panel.title = "Open Markdown Folder"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK, let url = panel.url {
            addFolderTab(rootFolderURL: url)
        }
    }
    
    func addFolderTab(rootFolderURL: URL) {
        // If already exists, switch to it
        if let existing = tabs.first(where: { $0.rootFolderURL.standardizedFileURL == rootFolderURL.standardizedFileURL }) {
            selectTab(existing.id)
            return
        }
        
        let newTab = WorkspaceTab(rootFolderURL: rootFolderURL)
        tabs.append(newTab)
        selectTab(newTab.id)
        saveSession()
    }
    
    func selectTab(_ tabID: UUID) {
        if let index = tabs.firstIndex(where: { $0.id == tabID }) {
            tabs[index].lastAccessedAt = Date()
            selectedTabID = tabID
            saveSession()
        }
    }
    
    func closeTab(_ tabID: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        
        let wasSelected = (selectedTabID == tabID)
        tabs.remove(at: index)
        
        if wasSelected {
            if tabs.isEmpty {
                selectedTabID = nil
            } else {
                let nextIndex = min(index, tabs.count - 1)
                selectedTabID = tabs[nextIndex].id
            }
        }
        saveSession()
    }
    
    func updateSelectedFile(_ fileURL: URL?) {
        guard let id = selectedTabID, let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs[index].selectedFileURL = fileURL
        saveSession()
    }
    
    private func saveSession() {
        do {
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: savedTabsKey)
            if let id = selectedTabID {
                UserDefaults.standard.set(id.uuidString, forKey: savedSelectedTabKey)
            } else {
                UserDefaults.standard.removeObject(forKey: savedSelectedTabKey)
            }
        } catch {
            print("Failed to save workspace session: \(error)")
        }
    }
    
    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: savedTabsKey) else { return }
        do {
            let restoredTabs = try JSONDecoder().decode([WorkspaceTab].self, from: data)
            self.tabs = restoredTabs
            
            if let idString = UserDefaults.standard.string(forKey: savedSelectedTabKey),
               let id = UUID(uuidString: idString) {
                self.selectedTabID = id
            } else {
                self.selectedTabID = restoredTabs.first?.id
            }
        } catch {
            print("Failed to restore workspace session: \(error)")
        }
    }
}
