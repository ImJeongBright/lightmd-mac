import SwiftUI

struct FolderTabBarView: View {
    @EnvironmentObject var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var appearance: ReaderAppearanceSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var hoveredTabID: UUID?

    private var colors: AppColors {
        appearance.resolvedColors(for: colorScheme)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(workspaceViewModel.tabs) { tab in
                    tabView(for: tab)
                }
                
                Button(action: {
                    workspaceViewModel.openFolderWithPanel()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.tertiaryText)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(colors.hoverBackground)
                        )
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(colors.sidebarBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(colors.divider)
                .frame(height: 1)
        }
    }
    
    @ViewBuilder
    private func tabView(for tab: WorkspaceTab) -> some View {
        let isSelected = workspaceViewModel.selectedTabID == tab.id
        let isHovered = hoveredTabID == tab.id
        
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "folder")
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? colors.accent : colors.tertiaryText)
                
                Text(tab.title)
                    .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? colors.primaryText : colors.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 150)
                
                Button(action: {
                    workspaceViewModel.closeTab(tab.id)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(isHovered ? colors.secondaryText : Color.clear)
                        .padding(3)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isHovered ? colors.hoverBackground : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered && !isSelected ? colors.hoverBackground : Color.clear)
            )
            
            // Accent underline for selected tab
            Rectangle()
                .fill(isSelected ? colors.accent : Color.clear)
                .frame(height: 2)
                .padding(.horizontal, 4)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            workspaceViewModel.selectTab(tab.id)
        }
        .onHover { hovering in
            hoveredTabID = hovering ? tab.id : nil
        }
    }
}
