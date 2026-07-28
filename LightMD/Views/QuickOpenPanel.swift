import SwiftUI

struct QuickOpenPanel: View {
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    
    // Auto-focus TextField
    @FocusState private var isFocused: Bool
    
    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Input
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(colors.tertiaryText)
                
                TextField("Search pages...", text: $searchVM.quickOpenQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18))
                    .foregroundStyle(colors.primaryText)
                    .focused($isFocused)
                    .onSubmit {
                        searchVM.quickOpenConfirm()
                    }
                
                if !searchVM.quickOpenQuery.isEmpty {
                    Button(action: {
                        searchVM.quickOpenQuery = ""
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
            if searchVM.quickOpenResults.isEmpty {
                VStack {
                    Text("No results found")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(searchVM.quickOpenResults.enumerated()), id: \.element.id) { index, item in
                                QuickOpenItemView(
                                    item: item,
                                    isSelected: index == searchVM.quickOpenSelectedIndex,
                                    colors: colors
                                )
                                .id(index)
                                .onTapGesture {
                                    searchVM.quickOpenSelectedIndex = index
                                    searchVM.quickOpenConfirm()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 300)
                    .onChange(of: searchVM.quickOpenSelectedIndex) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: 500)
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

struct QuickOpenItemView: View {
    let item: QuickOpenItem
    let isSelected: Bool
    let colors: AppColors
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.system(size: 14, weight: isSelected ? .medium : .regular))
                .foregroundStyle(isSelected ? colors.appBackground : colors.primaryText) // Invert text if using accent background
            
            Text(item.relativePath)
                .font(.system(size: 11))
                .foregroundStyle(isSelected ? colors.appBackground.opacity(0.8) : colors.tertiaryText)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? colors.accent : Color.clear)
        .contentShape(Rectangle())
    }
}
