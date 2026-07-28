import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var isQuickOpenVisible = false
    @Published var isWorkspaceSearchVisible = false
    
    // Quick Open
    @Published var quickOpenQuery = ""
    @Published var quickOpenResults: [QuickOpenItem] = []
    @Published var quickOpenSelectedIndex: Int = 0
    
    // Workspace Search
    @Published var workspaceSearchQuery = ""
    @Published var workspaceSearchResults: [WorkspaceSearchResult] = []
    @Published var isSearching = false
    
    private let searchService = WorkspaceSearchService()
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    // Dependencies
    private weak var workspaceVM: WorkspaceViewModel?
    private weak var markdownVM: MarkdownViewModel?
    
    init() {
        setupBindings()
    }
    
    func inject(workspaceVM: WorkspaceViewModel, markdownVM: MarkdownViewModel) {
        self.workspaceVM = workspaceVM
        self.markdownVM = markdownVM
    }
    
    private func setupBindings() {
        // Debounce Workspace Search
        $workspaceSearchQuery
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performWorkspaceSearch(query: query)
            }
            .store(in: &cancellables)
            
        // Immediate update for Quick Open
        $quickOpenQuery
            .sink { [weak self] query in
                self?.performQuickOpenSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func showQuickOpen() {
        isWorkspaceSearchVisible = false
        quickOpenQuery = ""
        quickOpenSelectedIndex = 0
        isQuickOpenVisible = true
        performQuickOpenSearch(query: "")
    }
    
    func hideQuickOpen() {
        isQuickOpenVisible = false
    }
    
    func showWorkspaceSearch() {
        isQuickOpenVisible = false
        isWorkspaceSearchVisible = true
        // don't clear query immediately so they can see previous search
    }
    
    func hideWorkspaceSearch() {
        isWorkspaceSearchVisible = false
    }
    
    func selectQuickOpenItem(_ item: QuickOpenItem) {
        hideQuickOpen()
        markdownVM?.selectFile(item.fileURL)
    }
    
    func selectSearchResult(_ result: WorkspaceSearchResult) {
        hideWorkspaceSearch()
        markdownVM?.selectFile(result.fileURL)
        // MVP: Just load the file. Scrolling to line is an enhancement.
        // If we want to scroll, we can inject a request to the webview or save it.
    }
    
    // Navigation for Quick Open
    func quickOpenMoveUp() {
        if quickOpenSelectedIndex > 0 {
            quickOpenSelectedIndex -= 1
        } else if !quickOpenResults.isEmpty {
            quickOpenSelectedIndex = quickOpenResults.count - 1
        }
    }
    
    func quickOpenMoveDown() {
        if quickOpenSelectedIndex < quickOpenResults.count - 1 {
            quickOpenSelectedIndex += 1
        } else {
            quickOpenSelectedIndex = 0
        }
    }
    
    func quickOpenConfirm() {
        guard !quickOpenResults.isEmpty, quickOpenSelectedIndex < quickOpenResults.count else { return }
        selectQuickOpenItem(quickOpenResults[quickOpenSelectedIndex])
    }
    
    private func performQuickOpenSearch(query: String) {
        guard let folderURL = markdownVM?.folderURL, let files = markdownVM?.folderMarkdownFiles.map({ $0.url }) else {
            quickOpenResults = []
            return
        }
        
        quickOpenResults = searchService.searchFiles(query: query, in: folderURL, files: files)
        if quickOpenSelectedIndex >= quickOpenResults.count {
            quickOpenSelectedIndex = 0
        }
    }
    
    private func performWorkspaceSearch(query: String) {
        searchTask?.cancel()
        
        guard let folderURL = markdownVM?.folderURL, let files = markdownVM?.folderMarkdownFiles.map({ $0.url }), !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            workspaceSearchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        workspaceSearchResults = []
        
        searchTask = Task {
            let results = await searchService.searchContent(query: query, in: folderURL, files: files)
            if !Task.isCancelled {
                self.workspaceSearchResults = results
                self.isSearching = false
            }
        }
    }
}
