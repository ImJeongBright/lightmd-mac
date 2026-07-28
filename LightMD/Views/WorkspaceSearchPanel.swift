import SwiftUI

struct WorkspaceSearchPanel: View {
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var isFocused: Bool
    
    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Input
            HStack(spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(colors.tertiaryText)
                
                TextField("Search in workspace...", text: $searchVM.workspaceSearchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18))
                    .foregroundStyle(colors.primaryText)
                    .focused($isFocused)
                
                if searchVM.isSearching {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.trailing, 4)
                }
                
                if !searchVM.workspaceSearchQuery.isEmpty {
                    Button(action: {
                        searchVM.workspaceSearchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(colors.tertiaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            
            Divider()
                .overlay(colors.divider)
            
            // Results List
            if searchVM.workspaceSearchQuery.isEmpty {
                VStack {
                    Text("Type to search in all workspace files")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 32)
            } else if searchVM.workspaceSearchResults.isEmpty && !searchVM.isSearching {
                VStack {
                    Text("No results found for \"\(searchVM.workspaceSearchQuery)\"")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchVM.workspaceSearchResults) { result in
                            WorkspaceSearchResultView(result: result, query: searchVM.workspaceSearchQuery, colors: colors)
                                .onTapGesture {
                                    searchVM.selectSearchResult(result)
                                }
                            
                            Divider()
                                .overlay(colors.divider.opacity(0.5))
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .frame(width: 550)
        .background(colors.appBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            isFocused = true
        }
    }
}

struct WorkspaceSearchResultView: View {
    let result: WorkspaceSearchResult
    let query: String
    let colors: AppColors
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "doc.text")
                    .font(.system(size: 12))
                    .foregroundStyle(colors.secondaryText)
                
                Text(result.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                
                if let line = result.lineNumber {
                    Text("Line \(line)")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.tertiaryText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(colors.hoverBackground)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(result.relativePath)
                    .font(.system(size: 11))
                    .foregroundStyle(colors.tertiaryText)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
            
            // Highlighted Snippet
            HighlightedText(text: result.snippet, query: query, colors: colors)
                .font(.system(size: 12))
                .lineLimit(2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(isHovered ? colors.hoverBackground : Color.clear)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// Simple highlighted text view
struct HighlightedText: View {
    let text: String
    let query: String
    let colors: AppColors
    
    var body: some View {
        if query.isEmpty {
            Text(text).foregroundColor(colors.secondaryText)
        } else {
            highlightedContent
        }
    }
    
    @ViewBuilder
    private var highlightedContent: some View {
        let lowerText = text.lowercased()
        let lowerQuery = query.lowercased()
        
        if let range = lowerText.range(of: lowerQuery) {
            let prefix = text[..<range.lowerBound]
            let match = text[range]
            let suffix = text[range.upperBound...]
            
            Text(String(prefix)).foregroundColor(colors.secondaryText)
                + Text(String(match)).foregroundColor(colors.accent).bold()
                + Text(String(suffix)).foregroundColor(colors.secondaryText)
        } else {
            Text(text).foregroundColor(colors.secondaryText)
        }
    }
}
