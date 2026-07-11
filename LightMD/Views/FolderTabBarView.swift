import SwiftUI

struct FolderTabBarView: View {
    @EnvironmentObject var workspaceViewModel: WorkspaceViewModel
    @Environment(\.colorScheme) private var colorScheme

    private var palette: DesignPalette {
        DesignSystem.palette(for: colorScheme)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(workspaceViewModel.tabs) { tab in
                    tabView(for: tab)
                }
                
                Button(action: {
                    workspaceViewModel.openFolderWithPanel()
                }) {
                    Image(systemName: "plus")
                        .padding(6)
                        .background(palette.toolbarControlBackground)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(palette.appBackground)
        .overlay(Divider().opacity(0.5), alignment: .bottom)
    }
    
    @ViewBuilder
    private func tabView(for tab: WorkspaceTab) -> some View {
        let isSelected = workspaceViewModel.selectedTabID == tab.id
        
        HStack(spacing: 6) {
            Image(systemName: "folder")
                .foregroundColor(isSelected ? palette.primaryText : palette.mutedText)
            
            Text(tab.title)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? palette.primaryText : palette.secondaryText)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 150)
            
            Button(action: {
                workspaceViewModel.closeTab(tab.id)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isSelected ? palette.secondaryText : palette.mutedText)
                    .padding(4)
                    .background(Color.primary.opacity(0.01))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? palette.documentSurface : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? palette.border : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            workspaceViewModel.selectTab(tab.id)
        }
    }
}
