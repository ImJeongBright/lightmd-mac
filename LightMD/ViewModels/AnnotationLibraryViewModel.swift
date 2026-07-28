import Foundation
import Combine

/// Loads all annotations from all sidecar files in the workspace and exposes them as a sorted list.
@MainActor
final class AnnotationLibraryViewModel: ObservableObject {
    @Published private(set) var entries: [AnnotationLibraryEntry] = []
    @Published private(set) var isLoading = false
    @Published var filterType: AnnotationType? = nil
    @Published var searchQuery = ""
    
    private var allEntries: [AnnotationLibraryEntry] = []
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    
    init() {
        setupFilterBinding()
    }
    
    private func setupFilterBinding() {
        Publishers.CombineLatest($filterType, $searchQuery)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] (type, query) in
                self?.applyFilters(type: type, query: query)
            }
            .store(in: &cancellables)
    }
    
    func load(from files: [URL]) {
        loadTask?.cancel()
        isLoading = true
        
        loadTask = Task {
            var loaded: [AnnotationLibraryEntry] = []
            
            for fileURL in files {
                if Task.isCancelled { break }
                let sidecar = SidecarStore.load(for: fileURL)
                let fileName = fileURL.deletingPathExtension().lastPathComponent
                
                for annotation in sidecar.annotations {
                    let entry = AnnotationLibraryEntry(
                        id: annotation.id,
                        annotation: annotation,
                        fileURL: fileURL,
                        fileName: fileName
                    )
                    loaded.append(entry)
                }
            }
            
            // Sort by most recently updated
            loaded.sort { $0.annotation.updatedAt > $1.annotation.updatedAt }
            
            if !Task.isCancelled {
                self.allEntries = loaded
                self.applyFilters(type: self.filterType, query: self.searchQuery)
                self.isLoading = false
            }
        }
    }
    
    func refresh(from files: [URL]) {
        load(from: files)
    }
    
    private func applyFilters(type: AnnotationType?, query: String) {
        var filtered = allEntries
        
        if let type {
            filtered = filtered.filter { $0.annotation.type == type }
        }
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedQuery.isEmpty {
            filtered = filtered.filter { entry in
                entry.fileName.lowercased().contains(trimmedQuery) ||
                entry.annotation.selector.exact.lowercased().contains(trimmedQuery) ||
                (entry.annotation.memo?.lowercased().contains(trimmedQuery) == true)
            }
        }
        
        entries = filtered
    }
    
    func exportToMarkdown() -> String {
        var result = "# Annotation Export\n\n"
        
        let grouped = Dictionary(grouping: entries, by: { $0.fileName })
        let sortedFiles = grouped.keys.sorted()
        
        for file in sortedFiles {
            result += "## \(file)\n\n"
            if let fileEntries = grouped[file] {
                for entry in fileEntries {
                    result += "- **\(entry.annotation.type.title)**: \(entry.annotation.selector.exact)\n"
                    if let memo = entry.annotation.memo, !memo.isEmpty {
                        result += "  - *Memo:* \(memo)\n"
                    }
                }
            }
            result += "\n"
        }
        
        return result
    }
}
