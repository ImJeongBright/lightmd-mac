# LightMD

[🇰🇷 한국어](./README.md) | [🇺🇸 English](./README.en.md) | [🇨🇳 中文](./README.zh.md)

LightMD는 SwiftUI로 구축된 작고 가벼운 네이티브 macOS 마크다운 리더입니다. 무거운 에디터를 열지 않고도 `README.md`, `architecture.md`, `agents.md`, `decision-log.md`와 같은 프로젝트 문서를 읽고 싶은 개발자를 위해 설계되었습니다.

포지셔닝: 개발 문서를 조용히 읽고, 작은 변경이 필요할 때만 편집 모드로 전환하세요.

## 요구 사항

- macOS 13 이상
- 일반적인 Xcode 프로젝트 워크플로우를 위한 Xcode 15 이상
- 가벼운 폴백(Fallback) 빌드를 위해서는 Apple Command Line Tools만으로 충분합니다.

## 실행 방법

Xcode에서 `LightMD.xcodeproj`를 열고 `LightMD` 스킴을 선택한 다음 앱을 실행합니다.

명령어 기반 빌드:

```sh
xcodebuild -project LightMD.xcodeproj -scheme LightMD -configuration Debug build
```

Xcode 전체 설치가 불가능한 경우, Command Line Tools를 사용하여 로컬 `.app` 번들을 빌드할 수 있습니다:

```sh
./build-clt.sh
open .build-clt/LightMD.app
```

이 폴백 경로는 SwiftUI 소스 파일을 `swiftc`로 직접 컴파일하고, 최소한의 macOS 앱 번들을 생성한 후 로컬에서 ad-hoc 서명을 수행합니다.

## 구현된 기능

- `LightMD`라는 이름의 네이티브 SwiftUI macOS 앱
- `.md` 및 `.markdown` 파일을 위한 `File > Open...` 및 툴바 열기 버튼
- 재귀적인 폴더 문서 모드를 위한 `Open Folder...`
- 헤딩, 문단, 목록, 작업 목록, 테이블, 인용구, 코드 블록, 구분선, 링크, 인라인 강조를 지원하는 리더(Reader) 모드
- 원본 마크다운 텍스트를 수정할 수 있는 편집(Edit) 모드
- 저장 버튼 및 `Cmd + S` 단축키
- 리더/편집 모드 전환 버튼 및 `Cmd + E` 단축키
- `UserDefaults`에 저장되는 최근 파일 목록 (최대 5개 제한)
- 마지막으로 열었던 파일/폴더 세션 복원
- 브라우저 방식의 앞/뒤 문서 탐색 (Back/Forward)
- 여러 개의 독립적인 리더 창 지원
- 내부 마크다운 링크 탐색 (Internal Markdown link navigation)
- 현재 문서 옆에 링크된 문서를 열어볼 수 있는 레퍼런스 창 (Reference Pane)
- 탐색 단축키: `Cmd + [`, `Cmd + ]`, `Cmd + Left`, `Cmd + Right`, `Option + Cmd + Left`, `Option + Cmd + Right`
- H1, H2, H3 헤딩을 기반으로 생성되는 아웃라인(개요) 사이드바
- 리더 모드에서 클릭 가능한 아웃라인 탐색
- 사이드카(Sidecar) 메타데이터에 즐겨찾는 헤딩 저장
- `architecture.md.lightmd.json`과 같은 이름으로 저장되는 사이드카 읽기 상태 파일
- `.md` 및 `.markdown` 파일을 위한 재귀적 파일 트리 사이드바
- 옵시디언(Obsidian) 스타일의 WikiLink 탐색 (`[[target]]`, `[[target|alias]]`, `[[#anchor]]`)
- 상단 주석 바(Annotation Bar)를 통한 텍스트 선택 기반 리더 주석: 하이라이트, 밑줄, 메모 및 지우기
- 코드 블록 복사 버튼
- 파일 이름, 모드, 편집 상태를 보여주는 미니멀한 macOS 스타일 툴바
- 제한된 너비, 편안한 간격, 튜닝된 마크다운 스타일링을 갖춘 리더 중심의 문서 카드 UI
- 고정폭 텍스트, 더 넓은 소스 레이아웃, 저장되지 않은 변경 상태 테두리를 갖춘 구분된 에디터 화면
- 시스템, 라이트, 다크 모드를 위한 앱 테마 선택기
- 로컬 파일 시스템 전용
- 외부 패키지 종속성 없음

## 작업 공간 탭 (Workspace Tabs)
여러 개의 마크다운 폴더를 동시에 열어둘 수 있습니다.
- **Open Folder...** (`Cmd + Shift + O`)를 사용하거나 탭 바의 `+` 아이콘을 클릭하여 워크스페이스에 다른 폴더를 추가할 수 있습니다.
- 각 탭은 고유한 파일 트리, WikiLink 인덱스 및 탐색 기록을 유지합니다.
- 활성화된 탭들은 앱을 다시 시작해도 저장되고 복원됩니다.

## UI 및 테마

LightMD는 기본적으로 시스템 모양을 따릅니다. 툴바 테마 메뉴를 통해 라이트 또는 다크 모드로 재정의할 수 있으며, 이 선택은 `UserDefaults`를 통해 로컬에 저장됩니다.

UI 스타일은 `LightMD/Design`에서 관리됩니다:

- `AppTheme.swift`는 `system`, `light`, `dark`를 정의합니다.
- `DesignSystem.swift`는 색상, 표면, 테두리, 그림자, 레이아웃 너비를 중앙에서 관리합니다.
- `MarkdownStyle.swift`는 마크다운 텍스트 크기와 간격을 중앙에서 관리합니다.

라이트 모드는 문서 표면과 가볍게 분리된 약간의 오프화이트(off-white) 앱 배경을 사용합니다. 다크 모드는 더 부드럽게 솟아오른 표면, 차분한 텍스트, 가라앉은 코드 블록, 저대비 테두리를 갖춘 차콜(charcoal) 배경을 사용합니다.

## 리더 중심 워크플로우

LightMD는 기본적으로 문서를 미리보기(Preview) 모드로 엽니다. `Cmd + E`를 누르거나 툴바 토글 버튼으로 편집 모드로 전환하기 전까지 편집 컨트롤은 최소화된 상태로 유지됩니다. `Cmd + E`를 다시 누르면 리더 모드로 돌아옵니다.

폴더를 열면 LightMD는 깊이(depth) 5까지 `.md` 및 `.markdown` 파일을 재귀적으로 스캔합니다. 숨김 파일과 폴더는 건너뛰며, `.git`, `node_modules`, `.build`, `.swiftpm`, `DerivedData`와 같이 일반적으로 생성되는 폴더는 제외됩니다.

왼쪽 문서(Docs) 사이드바는 열린 폴더를 접을 수 있는 파일 트리 형태로 보여줍니다. 폴더는 SF Symbols 폴더 아이콘을 사용하고, 마크다운 문서는 문서 아이콘을 사용하며, 현재 파일은 강조 표시됩니다. 파일을 선택하면 중앙 리더에서 열리고 브라우저와 같은 탐색 기록에 이동이 기록됩니다. 오른쪽 아웃라인 사이드바는 현재 문서의 H1-H3 구조를 보여줍니다.

읽기 상태는 원본 마크다운 소스 외부의 각 문서 옆에 있는 사이드카 JSON 파일에 저장됩니다. 현재 메타데이터에는 다음이 포함됩니다:

- 마지막으로 읽은 헤딩
- 즐겨찾기 헤딩 ID
- 마지막으로 본 타임스탬프
- 텍스트 선택 기반 주석 (정확도를 위해 정확한 일치와 오프셋 사용)

## 리더 주석 (Reader Annotations)

리더 주석은 텍스트 선택을 기반으로 합니다. 리더 모드에서 아무 텍스트나 드래그하여 선택하세요. 선택 이벤트는 성능을 위해 디바운스(debounce) 처리되며, 선택이 완료되면 메인 툴바 아래의 주석 바(Annotation Bar)가 활성화됩니다.

- 하이라이트 (Highlight)
- 밑줄 (Underline)
- 메모 (Memo)
- 지우기 (Clear)

하이라이트와 밑줄은 선택한 텍스트 범위에 정확하게 적용됩니다. 메모는 노트 편집을 위해 주석 바에서 컴팩트한 팝오버를 엽니다. 리더 본문에는 더 이상 마우스를 올렸을 때 떠다니는 주석 버튼이 표시되지 않아 읽는 동안 문서 표면이 더 깔끔하게 유지됩니다.

주석은 원본 마크다운 소스를 수정하지 않습니다. 문서 사이드카 파일에 저장됩니다. 예:

```text
architecture.md
architecture.md.lightmd.json
```

사이드카는 파일 경로, 마지막으로 열었거나 읽은 타임스탬프, 즐겨찾기 헤딩, 그리고 고유 ID와 텍스트 선택 앵커(정확한 텍스트, 접두사, 접미사, DOM 오프셋)로 매핑된 주석 기록을 저장합니다.

## 브라우저 형태의 탐색 (Browser-Like Navigation)

LightMD는 최근 파일 목록과 별개로 문서 탐색 기록을 보관합니다. 한 마크다운 파일에서 다른 마크다운 파일로 이동하면 `NavigationHistory`에 `DocumentLocation`이 기록되므로, 브라우저나 Finder처럼 뒤로 가기(Back)와 앞으로 가기(Forward)가 작동합니다.

사이드바 파일 선택, 내부 마크다운 링크, 동일 문서 내 헤딩 앵커 링크 모두 메인 창의 탐색 기록에 참여합니다. `DocumentLocation`은 파일 URL과 선택적인 앵커/헤딩 ID를 저장하여 향후 스크롤 복원 시 동일한 모델을 기반으로 작동할 수 있도록 합니다.

툴바 컨트롤:

- 뒤로 가기 (Back): `chevron.left`
- 앞으로 가기 (Forward): `chevron.right`

지원되는 단축키:

- `Cmd + N`: 비어 있는 새 리더 창 열기
- `Cmd + [`: 뒤로 가기
- `Cmd + ]`: 앞으로 가기
- `Cmd + Left`: 리더 모드에서 뒤로 가기
- `Cmd + Right`: 리더 모드에서 앞으로 가기
- `Option + Cmd + Left`: 리더 모드에서 뒤로 가기
- `Option + Cmd + Right`: 리더 모드에서 앞으로 가기

`Cmd + [` 및 `Cmd + ]`는 편집 모드에서도 사용할 수 있습니다. 화살표 기반 탐색은 일반적인 텍스트 편집 이동을 방해하지 않도록 리더 모드로 제한됩니다.

## 다중 창 지원 (Multiple Windows)

LightMD는 SwiftUI `WindowGroup`을 통해 여러 개의 macOS 창을 지원합니다.

- `Cmd + N`은 비어 있는 새 리더 창을 엽니다.
- 각 창은 자신만의 현재 파일, 폴더 컨텍스트, 미리보기/편집 모드, 레퍼런스 창 상태, 앞/뒤 탐색 기록을 소유합니다.
- 폴더 사이드바에서 마크다운 파일을 우클릭하고 `Open in New Window`를 선택하면 해당 문서를 별도의 창에서 엽니다.
- 내부 마크다운 링크를 `Cmd + Click` 하면 대상을 새 창에서 엽니다.

가능한 경우 폴더에서 열린 새 창은 동일한 루트 폴더 컨텍스트를 유지하여 사이드바를 계속 유용하게 사용할 수 있도록 합니다. 해당 컨텍스트를 사용할 수 없는 경우에도 새 창은 요청된 마크다운 파일을 직접 엽니다.

## 내부 마크다운 링크 (Internal Markdown Links)

마크다운 파일을 가리키는 리더 링크는 LightMD 내부에서 처리됩니다:

```markdown
[Architecture](./architecture.md)
[Auth API](./api/auth.md)
[Decision Log](../decision-log.md)
[Data Flow](./architecture.md#data-flow)
[Same Page](#api-design)
```

규칙:

- LightMD는 `WKWebView` 내부에서 실행되는 사용자 정의 HTML 생성기를 사용하여 마크다운 링크 탐색 및 블록 수준 주석을 안정적으로 지원합니다.
- `.md` 및 `.markdown` 링크는 먼저 현재 파일을 기준으로 확인된 다음, 사용 가능한 경우 열려 있는 루트 폴더를 기준으로 확인됩니다.
- 기존 내부 마크다운 링크는 현재 리더 창에서 열리며 뒤로/앞으로 탐색 기록에 추가됩니다.
- `#heading` 링크는 LightMD가 생성된 헤딩 앵커를 일치시킬 수 있을 때 해당 헤딩으로 스크롤합니다.
- 옵시디언 스타일의 WikiLinks(`[[target]]`)는 다음 순서로 대상 파일을 검색합니다:
  1. 현재 파일에서의 정확한 상대 경로
  2. 루트 폴더에서의 상대 경로
  3. (확장자를 무시한) 정규화된 스템 이름을 열려 있는 모든 마크다운 파일에서 검색
  4. 디렉터리 트리에서 가장 가까운 일치 항목을 우선순위로 선택
- 내부 마크다운 파일이나 WikiLink가 없으면 앱이 종료되지 않고 알림 창을 표시하며 현재 문서를 그대로 유지합니다.
- `http`, `https`, `mailto` 링크는 macOS 기본 브라우저/메일 앱에서 열리며 LightMD 탐색 기록에 추가되지 않습니다.
- 이미지 링크는 문서 탐색으로 간주되지 않습니다.

## 레퍼런스 창 (Reference Pane)

메인 문서의 위치를 잃지 않고 링크된 문서를 확인하고 싶을 때 레퍼런스 창을 사용하세요.

- 내부 마크다운 링크를 `Option + Click` 하면 오른쪽 레퍼런스 창에서 열립니다.
- 레퍼런스 창 안에서 클릭한 링크는 기본적으로 해당 창 내부에서 이동합니다.
- 레퍼런스 창은 메인 리더와 동일한 마크다운 렌더링 방식(테이블, 목록, 링크, 코드 블록 복사 버튼 포함)을 사용합니다.
- 창 헤더의 닫기 버튼을 사용하여 숨길 수 있습니다.

레퍼런스 창의 기록은 의도적으로 현재 작게 유지되어 있습니다: 아직 자체적인 앞/뒤 탐색 스택을 가지고 있지 않습니다.

## 아직 구현되지 않은 기능

- 화면 분할 편집 및 미리보기
- 코드 블록 내의 구문 강조(Syntax highlighting)
- 위지윅(WYSIWYG) 편집
- 링크 단위의 우클릭 메뉴 (`Open in Side Pane` / `Copy Link Path`)
- 레퍼런스 창 내부의 독립적인 앞/뒤 탐색 기록
- 가벼운 네이티브 렌더러를 넘어서는 전체 GitHub Flavored Markdown 커버리지
- 샌드박스 처리된 폴더 복원을 위한 보안 범위 북마크 (Security-scoped bookmarks)
- 클라우드 동기화, 계정, 플러그인, 그래프 뷰, AI 요약 또는 다중 기기 상태 동기화

## 샘플

샘플 마크다운 문서는 `Samples/` 아래에 포함되어 있습니다.

- `Samples/Sample.md`: 일반적인 리더 샘플
- `Samples/rendering-test.md`: 테이블, 코드, 링크 탐색 회귀(regression) 테스트 샘플
- `Samples/architecture.md` 및 `Samples/api/auth.md`: `rendering-test.md`의 링크 대상

## 향후 개선 사항

- 선택적인 에디터 레이아웃으로 분할 뷰(Split view) 추가
- 문서 내 찾기(Find-in-document) 추가
- 중첩된 목록 렌더링 개선
- 앱 아이콘 자산 추가
