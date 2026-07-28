import SwiftUI

struct AnnotationLibraryView: View {
    @EnvironmentObject private var viewModel: MarkdownViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var libraryVM = AnnotationLibraryViewModel()
    
    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    private let allTypes: [AnnotationType?] = [nil, .highlight, .underline, .textColor, .memo]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider().background(colors.divider)
            
            // Filter tabs
            filterBar
            
            Divider().background(colors.divider)
            
            // Content
            if libraryVM.isLoading {
                Spacer()
                ProgressView()
                    .controlSize(.small)
                Spacer()
            } else if libraryVM.entries.isEmpty {
                emptyState
            } else {
                annotationList
            }
        }
        .background(colors.appBackground)
        .onAppear {
            loadLibrary()
        }
        .onChange(of: viewModel.folderMarkdownFiles.count) { _ in
            loadLibrary()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 14))
                .foregroundColor(colors.accent)
            
            Text("Annotation Library")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(colors.primaryText)
            
            Spacer()
            
            // Search field
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(colors.tertiaryText)
                
                TextField("Search...", text: $libraryVM.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(colors.primaryText)
                    .frame(width: 120)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(colors.hoverBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(colors.border, lineWidth: 0.5)
                    )
            )
            
            Button(action: { exportAnnotations() }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 12))
                    .foregroundColor(colors.secondaryText)
            }
            .buttonStyle(.plain)
            .help("Export to Clipboard")
            
            Button(action: { loadLibrary() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundColor(colors.secondaryText)
            }
            .buttonStyle(.plain)
            .help("Refresh annotation library")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(allTypes, id: \.self) { type in
                    FilterChip(
                        label: type?.title ?? "All",
                        icon: iconName(for: type),
                        isSelected: libraryVM.filterType == type,
                        colors: colors
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            libraryVM.filterType = type
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Annotation List
    
    private var annotationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(libraryVM.entries) { entry in
                    AnnotationEntryRow(entry: entry, colors: colors) {
                        viewModel.selectFile(entry.fileURL)
                    }
                    
                    Divider()
                        .background(colors.divider.opacity(0.5))
                        .padding(.leading, 16)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: libraryVM.searchQuery.isEmpty && libraryVM.filterType == nil ? "bookmark" : "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(colors.tertiaryText)
            
            if libraryVM.searchQuery.isEmpty && libraryVM.filterType == nil {
                Text("No annotations yet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                Text("Highlight, underline, or add memos to your documents")
                    .font(.system(size: 12))
                    .foregroundColor(colors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            } else {
                Text("No matching annotations")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.secondaryText)
            }
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private func exportAnnotations() {
        let text = libraryVM.exportToMarkdown()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    private func loadLibrary() {
        libraryVM.load(from: viewModel.folderMarkdownFiles.map { $0.url })
    }
    
    private func iconName(for type: AnnotationType?) -> String {
        switch type {
        case .highlight: return "highlighter"
        case .underline: return "underline"
        case .textColor: return "paintbrush"
        case .memo:      return "note.text"
        case nil:        return "list.bullet"
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let colors: AppColors
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 12))
            }
            .foregroundColor(isSelected ? colors.appBackground : colors.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isSelected ? colors.accent : colors.hoverBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Annotation Entry Row

private struct AnnotationEntryRow: View {
    let entry: AnnotationLibraryEntry
    let colors: AppColors
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Type indicator
                typeIndicator
                
                // Content
                VStack(alignment: .leading, spacing: 5) {
                    // File name + date
                    HStack {
                        Text(entry.fileName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(colors.accent)
                        
                        Spacer()
                        
                        Text(entry.annotation.updatedAt, style: .date)
                            .font(.system(size: 10))
                            .foregroundColor(colors.tertiaryText)
                    }
                    
                    // Selected text
                    Text(entry.annotation.selector.exact)
                        .font(.system(size: 12))
                        .foregroundColor(colors.primaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Memo if present
                    if let memo = entry.annotation.memo, !memo.isEmpty {
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.system(size: 9))
                                .foregroundColor(colors.tertiaryText)
                                .padding(.top, 2)
                            
                            Text(memo)
                                .font(.system(size: 11))
                                .foregroundColor(colors.secondaryText)
                                .lineLimit(2)
                                .italic()
                        }
                        .padding(.top, 2)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHovered ? colors.hoverBackground : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    @ViewBuilder
    private var typeIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(typeColor(for: entry).opacity(0.2))
                .frame(width: 28, height: 28)
            
            Image(systemName: typeIconName(for: entry))
                .font(.system(size: 12))
                .foregroundColor(typeColor(for: entry))
        }
        .padding(.top, 2)
    }
    
    private func typeColor(for entry: AnnotationLibraryEntry) -> Color {
        switch entry.annotation.type {
        case .highlight:
            return Color(hex: entry.annotation.colorHex ?? "#FFEE88") ?? colors.annotationHighlight
        case .underline:
            return colors.annotationUnderline
        case .textColor:
            return Color(hex: entry.annotation.colorHex ?? "") ?? colors.accent
        case .memo:
            return colors.accent
        }
    }
    
    private func typeIconName(for entry: AnnotationLibraryEntry) -> String {
        switch entry.annotation.type {
        case .highlight: return "highlighter"
        case .underline: return "underline"
        case .textColor: return "paintbrush"
        case .memo: return "note.text"
        }
    }
}

// Convenience hex color init
private extension Color {
    init?(hex: String) {
        guard !hex.isEmpty else { return nil }
        let h = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        let r = Double((val >> 16) & 0xFF) / 255.0
        let g = Double((val >> 8) & 0xFF) / 255.0
        let b = Double(val & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
