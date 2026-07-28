# Theme Asset Research

본 문서는 LightMD의 Scene Theme 기능에 사용될 배경 에셋들의 후보와 라이선스 검증 과정을 기록합니다. 외부 에셋의 불명확한 라이선스로 인한 잠재적 문제를 방지하고자, CC0 및 Public Domain이 명확히 확인된 자료만을 선별하거나 앱 내에서 자체적으로 렌더링(SVG, Gradient)하는 방식을 우선으로 검토했습니다.

---

## 1. Clean Canvas
- **요구사항**: 깨끗한 warm white 캔버스, 종이 질감 최소화
- **조사결과**: 단색 배경에 미세한 SwiftUI 노이즈 필터를 혼합하는 것이 성능과 디자인 면에서 가장 깔끔함.
- **결정**: 외부 에셋 사용 안 함 (자체 생성)

## 2. Warm Library
- **요구사항**: 따뜻한 서재와 오래된 종이 느낌
- **Candidate 1 (Paper Texture)**
  - Title: Old Paper Texture
  - Creator: rawpixel
  - Original source: Wikimedia Commons / Rawpixel public domain collection
  - License: CC0 1.0 Universal (Public Domain)
  - Selected: 아니오
  - Reason: 해상도가 지나치게 높아(10MB 이상) 앱 용량을 증가시키고 렌더링 성능을 저하시킬 우려가 있음.
- **Candidate 2 (Generated Warm Noise)**
  - Creator: LightMD (자체 생성 SVG)
  - Intended usage: 배경
  - Selected: 예
  - Reason: 용량이 몇 바이트 단위로 극히 작고, 화질 저하 없이 무한대로 패턴 확장이 가능함. CSS `radial-gradient`와 결합하여 따뜻한 느낌 극대화 가능.

## 3. Aurora
- **요구사항**: blue, violet, teal 기반의 부드러운 오로라
- **Candidate 1 (Aurora Photo)**
  - Title: Northern Lights
  - Creator: Unsplash (Various)
  - License: Unsplash License
  - Selected: 아니오
  - Reason: 완전히 자유로운 Public Domain이 아니며, 사진 이미지를 확대해서 쓸 경우 pixelation 현상이 발생함.
- **Candidate 2 (SwiftUI Mesh Gradient / Radial Gradients)**
  - Creator: LightMD
  - Selected: 예
  - Reason: `RadialGradient` 및 투명도 겹침을 이용하면 SVG나 코드만으로 부드럽고 몽환적인 오로라 느낌을 사진보다 훨씬 유려하게 표현 가능함.

## 4. Midnight Nebula
- **요구사항**: 깊은 우주, 성운 느낌의 다크 테마
- **Candidate 1 (NASA Space Image)**
  - Title: Orion Nebula
  - Creator: NASA/ESA
  - Original source: NASA Image Library
  - License: Public Domain (NASA public policy)
  - Selected: 아니오
  - Reason: 라이선스는 완벽하지만 시각적 디테일(수많은 별, 복잡한 가스 구름)이 너무 강해 Reader 뒤에 깔릴 경우 글자 가독성을 심하게 훼손함.
- **Candidate 2 (Generated Star Field SVG)**
  - Creator: LightMD
  - Selected: 예
  - Reason: 아주 미세하고 희미한 점들만 포함된 벡터 Star field SVG를 만들고, 배경에 deep violet/navy 그라데이션을 깔면 가독성을 지키면서 우주 느낌을 낼 수 있음.

## 5. Blueprint
- **요구사항**: 기술 설계 도면 느낌의 파란색 배경과 옅은 격자선
- **Candidate 1 (Vintage Blueprint Image)**
  - Title: Blueprint Layout
  - Original source: Wikimedia Commons
  - License: Public Domain
  - Selected: 아니오
  - Reason: 실제 옛날 청사진 사진은 얼룩과 스크래치가 포함되어 있어 가독성을 떨어뜨림.
- **Candidate 2 (Generated SVG Blueprint Grid)**
  - Creator: LightMD
  - Selected: 예
  - Reason: 완벽하게 일정한 굵기와 투명도를 가진 벡터 그리드(Grid)를 SVG로 생성하여 배경에 깔고, Reader 영역에만 `backdrop-filter: blur` 처리를 하는 것이 가장 모던함.

## 6. Forest Terminal
- **요구사항**: 숲 느낌의 딥 그린 베이스와 지형도(Topography) 패턴
- **Candidate 1 (Topographic Map Vector)**
  - Creator: SVGBackgrounds 또는 오픈소스 패턴 저장소
  - License: CC-BY 4.0 (Attribution required)
  - Selected: 아니오
  - Reason: 저작자 표기가 필수이며, 앱 내에 불필요한 크레딧 화면을 강제함.
- **Candidate 2 (Generated Topographic SVG)**
  - Creator: LightMD
  - Selected: 예
  - Reason: Bezier curve를 직접 수학적으로 단순화해 그린 SVG 에셋을 앱 내부에 번들링. 아주 미세한 opacity(0.05)로 적용하여 은은한 터미널+숲 느낌 제공.

---

## 결론 및 구현 방침

모든 후보를 검토한 결과, 외부 이미지 에셋을 직접 삽입하는 것은 **용량 문제, 화질 깨짐(pixelation), 가독성 저하, 라이선스 추적의 어려움**을 유발합니다. 

따라서 사용자의 요구사항(`외부 에셋보다 자체 생성 우선`, `가독성 보호`, `앱 성능 기준 만족`)에 부합하기 위해, **모든 Scene Theme의 배경을 100% 자체 생성 에셋(코드 기반 Gradient, 경량화된 SVG 패턴)으로 구현**하기로 결정했습니다. 이는 LightMD의 설치 용량을 1MB 이하로 유지하면서도 무한대 해상도(Retina Display)에서 완벽하게 선명한 테마 환경을 제공합니다.
