# LightMD

[🇰🇷 한국어](./README.md) | [🇺🇸 English](./README.en.md) | [🇨🇳 中文](./README.zh.md)

LightMD is a small native macOS Markdown reader built with SwiftUI. It is designed for developers who want to read project documents like `README.md`, `architecture.md`, `agents.md`, and `decision-log.md` without opening a heavy editor.

Positioning: read developer documentation quietly, then switch to edit mode only when a small change is needed.

## Requirements

- macOS 13 or later
- Xcode 15 or later for the normal Xcode project workflow
- Apple Command Line Tools are enough for the lightweight fallback build

## Run

Open `LightMD.xcodeproj` in Xcode, select the `LightMD` scheme, then run the app.

Command line build:

```sh
xcodebuild -project LightMD.xcodeproj -scheme LightMD -configuration Debug build
```

If full Xcode cannot be installed, build a local `.app` bundle with Command Line Tools:

```sh
./build-clt.sh
open .build-clt/LightMD.app
```

This fallback path compiles the SwiftUI source files directly with `swiftc`, creates a minimal macOS app bundle, and ad-hoc signs it locally.

## Implemented

- Native SwiftUI macOS app named `LightMD`
- `File > Open...` and toolbar open button for `.md` and `.markdown` files
- `Open Folder...` for recursive folder docs mode
- Reader mode for headings, paragraphs, lists, task lists, tables, blockquotes, code fences, dividers, links, and inline emphasis
- Edit mode for modifying raw Markdown text
- Save button and `Cmd + S`
- Reader/Edit toggle button and `Cmd + E`
- Recent files list persisted in `UserDefaults`, capped at 5 files
- Last opened file/folder session restore
- Browser-like Back/Forward document navigation
- Multiple independent reader windows
- Internal Markdown link navigation
- Reference Pane for opening linked documents beside the current document
- Navigation shortcuts: `Cmd + [`, `Cmd + ]`, `Cmd + Left`, `Cmd + Right`, `Option + Cmd + Left`, `Option + Cmd + Right`
- Outline sidebar generated from H1, H2, and H3 headings
- Clickable outline navigation in Reader mode
- Favorite headings stored in sidecar metadata
- Sidecar reading state files named like `architecture.md.lightmd.json`
- Recursive file tree sidebar for `.md` and `.markdown` files
- Obsidian-style WikiLink navigation (`[[target]]`, `[[target|alias]]`, `[[#anchor]]`)
- Text selection-based Reader annotations through the top Annotation Bar: Highlight, Underline, Memo, and Clear
- Code block copy button
- Minimal macOS-style toolbar with file name, mode, and edited state
- Reader-focused document card with constrained width, comfortable spacing, and tuned Markdown styling
- Distinct editor surface with monospace text, wider source layout, and unsaved-change border state
- App theme picker for System, Light, and Dark modes
- Local file system only
- No external packages

## Workspace Tabs
You can now open multiple markdown folders simultaneously. 
- Use **Open Folder...** (Cmd + Shift + O) or click the `+` icon on the tab bar to add another folder to your workspace.
- Each tab maintains its own file tree, WikiLink index, and navigation history.
- The active tabs are saved across app launches.

## UI and Theme

LightMD follows the system appearance by default. The toolbar theme menu can override this with Light or Dark mode, and the choice is stored locally with `UserDefaults`.

The UI styles are kept in `LightMD/Design`:

- `AppTheme.swift` defines `system`, `light`, and `dark`
- `DesignSystem.swift` centralizes colors, surfaces, borders, shadows, and layout widths
- `MarkdownStyle.swift` centralizes Markdown text sizing and spacing

Light mode uses an off-white app background with a lightly separated document surface. Dark mode uses a charcoal background with a softer raised surface, muted text, subdued code blocks, and low-contrast borders.

## Reader-First Workflow

LightMD opens documents in Preview mode by default. Editing controls stay minimal until `Cmd + E` or the toolbar toggle switches into Edit mode. Pressing `Cmd + E` again returns to the reader.

When a folder is opened, LightMD recursively scans `.md` and `.markdown` files up to depth 5. Hidden files and folders are skipped, and common generated folders such as `.git`, `node_modules`, `.build`, `.swiftpm`, and `DerivedData` are excluded.

The left Docs sidebar shows the opened folder as a collapsible file tree. Folders use SF Symbols folder icons, Markdown documents use document icons, and the current file is highlighted. Selecting a file opens it in the central reader and records the move in browser-like navigation history. The right Outline sidebar shows H1-H3 structure for the current document.

Reading state is stored outside the Markdown source in a sidecar JSON file next to each document. Current metadata includes:

- Last read heading
- Favorite heading IDs
- Last viewed timestamp
- Text selection-based annotations (using exact match and offsets for accuracy)

## Folder Docs Mode

Use `Open Folder...` from the toolbar or `Cmd + Shift + O`, then choose a documentation folder such as `/docs` or a project folder containing Markdown files.

The sidebar preserves folder structure:

```text
project-docs
  README.md
  architecture.md
  api
    auth.md
    user.md
```

LightMD keeps folder access active while the app is running. This lightweight build does not yet persist security-scoped bookmarks, so sandboxed future builds may need bookmark support for guaranteed folder restoration after relaunch.

## Reader Annotations

Reader annotations are based on text selection. Drag to select any text in Reader mode. The selection event is debounced for performance, and once a selection is made, the Annotation Bar under the main toolbar becomes active.

- Highlight
- Underline
- Memo
- Clear

Highlight and underline apply accurately to the selected text range. Memo opens a compact popover from the Annotation Bar for editing the note. The Reader body no longer shows hover-floating annotation buttons, keeping the document surface cleaner while reading.

Annotations do not modify the Markdown source. They are saved in the document sidecar file, for example:

```text
architecture.md
architecture.md.lightmd.json
```

The sidecar stores the file path, last opened/read timestamps, favorite headings, and annotation records keyed by unique IDs and text selection anchors (exact text, prefix, suffix, and DOM offsets).

## Browser-Like Navigation

LightMD keeps document navigation separate from the recent files list. Moving from one Markdown file to another records a `DocumentLocation` in `NavigationHistory`, so Back and Forward work like a browser or Finder.

Sidebar file selection, internal Markdown links, and same-document heading anchor links all participate in the main pane navigation history. `DocumentLocation` stores the file URL and an optional anchor/heading ID so future scroll restoration can build on the same model.

Toolbar controls:

- Back: `chevron.left`
- Forward: `chevron.right`

Supported shortcuts:

- `Cmd + N`: New empty reader window
- `Cmd + [`: Navigate Back
- `Cmd + ]`: Navigate Forward
- `Cmd + Left`: Navigate Back in Reader mode
- `Cmd + Right`: Navigate Forward in Reader mode
- `Option + Cmd + Left`: Navigate Back in Reader mode
- `Option + Cmd + Right`: Navigate Forward in Reader mode

`Cmd + [` and `Cmd + ]` are available from Edit mode too. Arrow-based navigation is limited to Reader mode to avoid interfering with normal text editing movement.

## Multiple Windows

LightMD supports multiple macOS windows through SwiftUI `WindowGroup`.

- `Cmd + N` opens a new empty reader window.
- Each window owns its own current file, folder context, Preview/Edit mode, Reference Pane state, and Back/Forward history.
- Right-click a Markdown file in the folder sidebar and choose `Open in New Window` to open that document in a separate window.
- `Cmd + Click` an internal Markdown link to open the target in a new window.

When possible, new windows opened from a folder keep the same root folder context so the sidebar remains useful. If that context is unavailable, the new window still opens the requested Markdown file directly.

## Internal Markdown Links

Reader links are handled inside LightMD when they point to Markdown files:

```markdown
[Architecture](./architecture.md)
[Auth API](./api/auth.md)
[Decision Log](../decision-log.md)
[Data Flow](./architecture.md#data-flow)
[Same Page](#api-design)
```

Rules:

- LightMD uses a custom HTML generator running inside a `WKWebView` to reliably support Markdown link navigation and block-level annotations.
- `.md` and `.markdown` links are resolved relative to the current file first, then against the open root folder when available.
- Existing internal Markdown links open in the current Reader pane and are recorded in Back/Forward history.
- `#heading` links scroll to the matching heading when LightMD can match the generated heading anchor.
- Obsidian-style WikiLinks (`[[target]]`) search for the target file in the following order:
  1. Exact relative path from the current file
  2. Relative path from the root folder
  3. Normalized stem name (ignoring extensions) across all opened Markdown files
  4. The closest match in the directory tree is chosen as a tie-breaker
- Missing internal Markdown files or WikiLinks show a non-crashing alert and leave the current document unchanged.
- `http`, `https`, and `mailto` links open in the macOS default browser/mail app and are not added to LightMD navigation history.
- Image links are not treated as document navigation.

## Reference Pane

Use the Reference Pane when you want to inspect a linked document without losing your place in the main document.

- `Option + Click` an internal Markdown link to open it in the right Reference Pane.
- Links clicked inside the Reference Pane navigate inside that pane by default.
- The Reference Pane uses the same Markdown rendering path as the main Reader, including tables, lists, links, and code block copy buttons.
- Use the close button in the pane header to hide it.

Reference Pane history is intentionally small for now: it does not yet have its own Back/Forward stack.

## Not Implemented

- Split view editing and preview
- Syntax highlighting inside code blocks
- WYSIWYG editing
- Per-link right-click menu for `Open in Side Pane` / `Copy Link Path`
- Independent Back/Forward history inside the Reference Pane
- Full GitHub Flavored Markdown coverage beyond the lightweight native renderer
- Security-scoped bookmarks for sandboxed folder restoration
- Cloud sync, accounts, plugins, graph view, AI summary, or multi-device state

## Sample

Sample Markdown documents are included under `Samples/`.

- `Samples/Sample.md`: general reader sample
- `Samples/rendering-test.md`: table, code, and link navigation regression sample
- `Samples/architecture.md` and `Samples/api/auth.md`: link targets for `rendering-test.md`

## Next Improvements

- Add split view as an optional editor layout
- Add find-in-document
- Improve nested list rendering
- Add app icon assets
