# LightMD

[🇰🇷 한국어](./README.md) | [🇺🇸 English](./README.en.md) | [🇨🇳 中文](./README.zh.md)

LightMD 是一款由 SwiftUI 构建的小巧原生 macOS Markdown 阅读器。它是为那些希望在不打开笨重编辑器的情况下，安静地阅读 `README.md`、`architecture.md`、`agents.md` 和 `decision-log.md` 等项目文档的开发者而设计的。

定位：安静地阅读开发者文档，仅在需要进行小幅修改时切换到编辑模式。

## 运行要求

- macOS 13 或更高版本
- 适用于标准 Xcode 项目工作流的 Xcode 15 或更高版本
- 对于轻量级的备用构建方式，只需安装 Apple Command Line Tools 即可

## 运行方法

在 Xcode 中打开 `LightMD.xcodeproj`，选择 `LightMD` 方案 (Scheme)，然后运行该应用程序。

命令行构建：

```sh
xcodebuild -project LightMD.xcodeproj -scheme LightMD -configuration Debug build
```

如果无法安装完整的 Xcode，可以使用 Command Line Tools 在本地构建一个 `.app` 应用程序包：

```sh
./build-clt.sh
open .build-clt/LightMD.app
```

这种备用构建方式将使用 `swiftc` 直接编译 SwiftUI 源文件，创建一个最小的 macOS 应用程序包，并在本地进行 ad-hoc 签名。

## 已实现的功能

- 名为 `LightMD` 的原生 SwiftUI macOS 应用程序
- 支持 `.md` 和 `.markdown` 文件的 `File > Open...` 和工具栏打开按钮
- 用于递归文件夹文档模式的 `Open Folder...`
- 阅读器 (Reader) 模式支持标题、段落、列表、任务列表、表格、块引用、代码块、分割线、链接和内联强调
- 用于修改原始 Markdown 文本的编辑 (Edit) 模式
- 保存按钮和 `Cmd + S`
- 阅读器/编辑模式切换按钮和 `Cmd + E`
- 持久化保存在 `UserDefaults` 中的最近文件列表，最多 5 个文件
- 恢复上次打开的文件/文件夹会话
- 类似浏览器的后退/前进 (Back/Forward) 文档导航
- 多个独立的阅读器窗口
- 内部 Markdown 链接导航
- 参考窗格 (Reference Pane)，用于在当前文档旁打开链接的文档
- 导航快捷键：`Cmd + [`、`Cmd + ]`、`Cmd + Left`、`Cmd + Right`、`Option + Cmd + Left`、`Option + Cmd + Right`
- 根据 H1、H2 和 H3 标题生成的大纲侧边栏
- 阅读器模式下可点击的大纲导航
- 将收藏的标题保存在 sidecar 元数据中
- 命名类似 `architecture.md.lightmd.json` 的 sidecar 阅读状态文件
- 适用于 `.md` 和 `.markdown` 文件的递归文件树侧边栏
- 类似 Obsidian 的 WikiLink 导航 (`[[target]]`, `[[target|alias]]`, `[[#anchor]]`)
- 通过顶部注释栏 (Annotation Bar) 实现基于文本选择的阅读器注释：高亮 (Highlight)、下划线 (Underline)、备忘录 (Memo) 和清除 (Clear)
- 代码块复制按钮
- 极简的 macOS 风格工具栏，显示文件名、模式和编辑状态
- 专注于阅读的文档卡片，具有受限的宽度、舒适的间距和优化的 Markdown 样式
- 独特的编辑器界面，具有等宽文本、更宽的源码布局以及未保存更改时的边框状态
- 应用程序主题选择器，支持系统、浅色和深色模式
- 仅支持本地文件系统
- 无外部包依赖

## 工作区标签页 (Workspace Tabs)
您现在可以同时打开多个 Markdown 文件夹。
- 使用 **Open Folder...** (`Cmd + Shift + O`) 或点击标签栏上的 `+` 图标，将另一个文件夹添加到工作区。
- 每个标签页维护各自的文件树、WikiLink 索引和导航历史记录。
- 活动的标签页将在应用重启后保留并恢复。

## UI 和主题

LightMD 默认遵循系统外观。您可以通过工具栏主题菜单将其覆盖为浅色或深色模式，此选择会使用 `UserDefaults` 在本地保存。

UI 样式统一存放在 `LightMD/Design` 目录中：

- `AppTheme.swift` 定义了 `system`、`light` 和 `dark`
- `DesignSystem.swift` 集中管理颜色、表面、边框、阴影和布局宽度
- `MarkdownStyle.swift` 集中管理 Markdown 文本的尺寸和间距

浅色模式使用灰白色应用程序背景，与文档表面轻微分离。深色模式使用炭黑色背景，搭配更柔和的凸起表面、柔和的文本、弱化的代码块以及低对比度边框。

## 优先阅读的工作流

LightMD 默认在预览 (Preview) 模式下打开文档。除非按下 `Cmd + E` 或使用工具栏切换到编辑模式，否则编辑控件会保持最小化。再次按下 `Cmd + E` 即可返回阅读器。

打开文件夹时，LightMD 会递归扫描 `.md` 和 `.markdown` 文件，最大深度为 5。隐藏的文件和文件夹将被跳过，并且排除了诸如 `.git`、`node_modules`、`.build`、`.swiftpm` 和 `DerivedData` 等常见的生成文件夹。

左侧的文档 (Docs) 侧边栏以可折叠的文件树形式显示已打开的文件夹。文件夹使用 SF Symbols 文件夹图标，Markdown 文档使用文档图标，当前文件高亮显示。选择一个文件将在中央阅读器中打开它，并将该操作记录在类似浏览器的导航历史记录中。右侧的大纲侧边栏显示当前文档的 H1-H3 结构。

阅读状态独立于 Markdown 源文件存储，保存在每个文档旁边的 sidecar JSON 文件中。目前的元数据包括：

- 上次阅读的标题
- 收藏的标题 ID
- 上次查看的时间戳
- 基于文本选择的注释（使用精确匹配和偏移量来确保准确性）

## 阅读器注释 (Reader Annotations)

阅读器注释基于文本选择。在阅读器模式下拖动即可选择任何文本。选择事件经过防抖 (debounce) 处理以提高性能。一旦选中文字，主工具栏下方的注释栏 (Annotation Bar) 就会激活。

- 高亮 (Highlight)
- 下划线 (Underline)
- 备忘录 (Memo)
- 清除 (Clear)

高亮和下划线会准确应用于选定的文本范围。点击备忘录会从注释栏弹出一个紧凑的弹出窗口，用于编辑笔记。阅读器正文在鼠标悬停时不再显示浮动的注释按钮，从而在阅读时保持文档表面更加整洁。

注释不会修改 Markdown 源文件。它们保存在文档 sidecar 文件中，例如：

```text
architecture.md
architecture.md.lightmd.json
```

Sidecar 文件保存了文件路径、上次打开/阅读的时间戳、收藏的标题以及由唯一 ID 和文本选择锚点（精确文本、前缀、后缀和 DOM 偏移量）所键控的注释记录。

## 类似浏览器的导航 (Browser-Like Navigation)

LightMD 将文档导航与最近文件列表分开。从一个 Markdown 文件移动到另一个文件时，会在 `NavigationHistory` 中记录一个 `DocumentLocation`，因此后退 (Back) 和前进 (Forward) 功能就像浏览器或 Finder 一样工作。

侧边栏文件选择、内部 Markdown 链接和同一文档中的标题锚点链接，都参与主窗格的导航历史记录。`DocumentLocation` 存储文件 URL 和可选的锚点/标题 ID，以便将来的滚动恢复可以建立在相同的模型之上。

工具栏控件：

- 后退 (Back)：`chevron.left`
- 前进 (Forward)：`chevron.right`

支持的快捷键：

- `Cmd + N`：新建一个空的阅读器窗口
- `Cmd + [`：后退导航
- `Cmd + ]`：前进导航
- `Cmd + Left`：在阅读器模式下后退
- `Cmd + Right`：在阅读器模式下前进
- `Option + Cmd + Left`：在阅读器模式下后退
- `Option + Cmd + Right`：在阅读器模式下前进

`Cmd + [` 和 `Cmd + ]` 在编辑模式下也可用。基于方向键的导航仅限于阅读器模式，以避免干扰正常的文本编辑移动。

## 多窗口支持 (Multiple Windows)

LightMD 通过 SwiftUI 的 `WindowGroup` 支持多个 macOS 窗口。

- `Cmd + N` 会打开一个新的空阅读器窗口。
- 每个窗口都拥有自己独立的当前文件、文件夹上下文、预览/编辑模式、参考窗格状态以及后退/前进历史记录。
- 在文件夹侧边栏中右键点击一个 Markdown 文件并选择 `Open in New Window`，可在单独的窗口中打开该文档。
- `Cmd + Click` 内部 Markdown 链接，可在新窗口中打开目标文件。

在可能的情况下，从文件夹打开的新窗口会保持相同的根文件夹上下文，以使侧边栏依然可用。如果该上下文不可用，新窗口仍将直接打开请求的 Markdown 文件直接。

## 内部 Markdown 链接 (Internal Markdown Links)

当阅读器中的链接指向 Markdown 文件时，会在 LightMD 内部处理：

```markdown
[Architecture](./architecture.md)
[Auth API](./api/auth.md)
[Decision Log](../decision-log.md)
[Data Flow](./architecture.md#data-flow)
[Same Page](#api-design)
```

规则：

- LightMD 使用在 `WKWebView` 内部运行的自定义 HTML 生成器，以可靠地支持 Markdown 链接导航和块级注释。
- `.md` 和 `.markdown` 链接首先相对于当前文件解析，然后在可能的情况下相对于已打开的根文件夹解析。
- 现有的内部 Markdown 链接将在当前阅读器窗格中打开，并记录在后退/前进历史记录中。
- 当 LightMD 能匹配生成的标题锚点时，`#heading` 链接会滚动到匹配的标题。
- Obsidian 风格的 WikiLink (`[[target]]`) 会按以下顺序搜索目标文件：
  1. 当前文件的准确相对路径
  2. 根文件夹的相对路径
  3. 跨所有已打开 Markdown 文件的归一化词干名称（忽略扩展名）
  4. 选择目录树中最接近的匹配项作为决胜条件
- 缺失的内部 Markdown 文件或 WikiLink 会显示不会导致崩溃的警告弹窗，并保持当前文档不变。
- `http`、`https` 和 `mailto` 链接会在 macOS 默认浏览器/邮件应用程序中打开，并且不会添加到 LightMD 导航历史记录中。
- 图片链接不会被视为文档导航。

## 参考窗格 (Reference Pane)

当您想在不丢失主文档位置的情况下检查链接文档时，请使用参考窗格。

- `Option + Click` 内部 Markdown 链接，将其在右侧的参考窗格中打开。
- 默认情况下，在参考窗格内点击的链接会在该窗格内进行导航。
- 参考窗格使用与主阅读器相同的 Markdown 渲染路径，包括表格、列表、链接和代码块复制按钮。
- 使用窗格标题中的关闭按钮可以将其隐藏。

参考窗格的历史记录目前有意保持简短：它尚未拥有独立的后退/前进堆栈。

## 尚未实现的功能

- 分屏视图编辑和预览
- 代码块内部的语法高亮
- 所见即所得 (WYSIWYG) 编辑
- 每个链接的右键菜单（`Open in Side Pane` / `Copy Link Path`）
- 参考窗格内独立的后退/前进历史记录
- 超出轻量级原生渲染器范围的完整 GitHub Flavored Markdown 覆盖
- 针对沙盒化文件夹恢复的安全范围书签 (Security-scoped bookmarks)
- 云同步、帐户、插件、关系图谱视图、AI 摘要或多设备状态同步

## 示例

示例 Markdown 文档位于 `Samples/` 目录下。

- `Samples/Sample.md`：常规阅读器示例
- `Samples/rendering-test.md`：表格、代码和链接导航回归测试示例
- `Samples/architecture.md` 和 `Samples/api/auth.md`：`rendering-test.md` 的链接目标

## 下一步改进计划

- 添加分屏视图作为可选的编辑器布局
- 添加文档内查找功能
- 改善嵌套列表的渲染
- 添加应用程序图标资源
