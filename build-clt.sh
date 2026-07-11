#!/bin/zsh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build-clt"
APP_DIR="$BUILD_DIR/LightMD.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ARCH="$(uname -m)"

case "$ARCH" in
  arm64)
    SWIFT_TARGET="arm64-apple-macos13.0"
    ;;
  x86_64)
    SWIFT_TARGET="x86_64-apple-macos13.0"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

swiftc \
  -module-cache-path /tmp/LightMDModuleCache \
  -target "$SWIFT_TARGET" \
  -o "$MACOS_DIR/LightMD" \
  "$PROJECT_DIR/LightMD/LightMDApp.swift" \
  "$PROJECT_DIR/LightMD/ContentView.swift" \
  "$PROJECT_DIR/LightMD/Design/AppTheme.swift" \
  "$PROJECT_DIR/LightMD/Design/DesignSystem.swift" \
  "$PROJECT_DIR/LightMD/Design/MarkdownStyle.swift" \
  "$PROJECT_DIR/LightMD/Models/DocumentLocation.swift" \
  "$PROJECT_DIR/LightMD/Models/DocumentWindowRequest.swift" \
  "$PROJECT_DIR/LightMD/Models/FileTreeNode.swift" \
  "$PROJECT_DIR/LightMD/Models/TextAnnotationSelector.swift" \
  "$PROJECT_DIR/LightMD/Models/MarkdownAnnotation.swift" \
  "$PROJECT_DIR/LightMD/Models/MarkdownHeading.swift" \
  "$PROJECT_DIR/LightMD/Models/ReaderPaneState.swift" \
  "$PROJECT_DIR/LightMD/Models/FolderDocument.swift" \
  "$PROJECT_DIR/LightMD/Models/SidecarMetadata.swift" \
  "$PROJECT_DIR/LightMD/Models/MarkdownDocument.swift" \
  "$PROJECT_DIR/LightMD/Models/ReaderAppearanceSettings.swift" \
  "$PROJECT_DIR/LightMD/ViewModels/AnnotationStore.swift" \
  "$PROJECT_DIR/LightMD/ViewModels/NavigationHistory.swift" \
  "$PROJECT_DIR/LightMD/ViewModels/MarkdownViewModel.swift" \
  "$PROJECT_DIR/LightMD/Views/AppearanceSettingsView.swift" \
  "$PROJECT_DIR/LightMD/Views/ToolbarView.swift" \
  "$PROJECT_DIR/LightMD/Views/AnnotationBarView.swift" \
  "$PROJECT_DIR/LightMD/Views/FolderDocsSidebarView.swift" \
  "$PROJECT_DIR/LightMD/Views/OutlineSidebarView.swift" \
  "$PROJECT_DIR/LightMD/Views/ReaderView.swift" \
  "$PROJECT_DIR/LightMD/Views/HTMLReaderView.swift" \
  "$PROJECT_DIR/LightMD/Views/ReferencePaneView.swift" \
  "$PROJECT_DIR/LightMD/Views/MemoPopoverView.swift" \
  "$PROJECT_DIR/LightMD/Views/EditorView.swift" \
  "$PROJECT_DIR/LightMD/Views/RecentFilesView.swift" \
  "$PROJECT_DIR/LightMD/Utils/FileLoader.swift" \
  "$PROJECT_DIR/LightMD/Utils/SidecarStore.swift" \
  "$PROJECT_DIR/LightMD/Models/WorkspaceTab.swift" \
  "$PROJECT_DIR/LightMD/ViewModels/WorkspaceViewModel.swift" \
  "$PROJECT_DIR/LightMD/ViewModels/FolderTreeStore.swift" \
  "$PROJECT_DIR/LightMD/Views/FolderTabBarView.swift" \
  "$PROJECT_DIR/LightMD/Utils/FolderMonitor.swift" \
  "$PROJECT_DIR/LightMD/Utils/MarkdownRenderer.swift" \
  "$PROJECT_DIR/LightMD/Utils/HTMLGenerator.swift" \
  "$PROJECT_DIR/LightMD/Services/FolderScanner.swift" \
  "$PROJECT_DIR/LightMD/Services/MarkdownFileIndex.swift" \
  "$PROJECT_DIR/LightMD/Services/MarkdownLinkResolver.swift"

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>LightMD</string>
  <key>CFBundleExecutable</key>
  <string>LightMD</string>
  <key>CFBundleIdentifier</key>
  <string>com.local.lightmd</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>LightMD</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.productivity</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"

if command -v codesign > /dev/null; then
  codesign --force --deep --sign - "$APP_DIR" > /dev/null
fi

echo "Built $APP_DIR"
echo "Run it with: open \"$APP_DIR\""
