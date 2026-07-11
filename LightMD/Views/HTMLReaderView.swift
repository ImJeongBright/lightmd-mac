import SwiftUI
import WebKit
import Combine



struct HTMLReaderView: NSViewRepresentable {
    @EnvironmentObject var viewModel: MarkdownViewModel
    @EnvironmentObject var appearance: ReaderAppearanceSettings
    @Environment(\.openURL) var openURL
    @ObservedObject var annotationStore: AnnotationStore
    let text: String
    let baseURL: URL?
    // Keep the binding so the parent interface stays the same,
    // but we don't use it for triggering – the Coordinator subscribes directly.
    @Binding var annotationApplyRequest: MarkdownViewModel.AnnotationApplyRequest?

    func makeNSView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        let ucc = WKUserContentController()
        ucc.add(context.coordinator, name: "textSelection")
        ucc.add(context.coordinator, name: "annotationClicked")
        ucc.add(context.coordinator, name: "debugLog")
        ucc.add(context.coordinator, name: "contextMenuAction")
        config.userContentController = ucc

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")

        context.coordinator.webView = webView
        context.coordinator.subscribeToViewModel()
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let currentAppearance = appearance.current
        
        // Reload HTML when document text changes or appearance settings change
        if context.coordinator.lastLoadedText != text || context.coordinator.lastAppearance != currentAppearance {
            context.coordinator.lastLoadedText = text
            context.coordinator.lastAppearance = currentAppearance
            context.coordinator.didFinishLoading = false
            context.coordinator.lastAppliedAnnotationsJSON = nil
            if let base = baseURL {
                webView.loadHTMLString(generateHTML(), baseURL: base)
            } else {
                webView.loadHTMLString(generateHTML(), baseURL: nil)
            }
            return
        }

        guard context.coordinator.didFinishLoading else { return }

        // Re-apply annotations when the store changes
        context.coordinator.applyAnnotationsIfNeeded()

        // Heading scroll
        if let req = viewModel.headingNavigationRequest,
           context.coordinator.lastNavigationRequestID != req.requestID {
            context.coordinator.lastNavigationRequestID = req.requestID
            webView.evaluateJavaScript(
                "var el=document.getElementById('\(req.headingID)');if(el)el.scrollIntoView({behavior:'smooth',block:'start'});",
                completionHandler: nil)
        }
    }

    private func generateHTML() -> String {
        let blocks = MarkdownRenderer.parse(text)
        return HTMLGenerator.generateHTML(from: blocks, appearance: appearance.current)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: HTMLReaderView
        weak var webView: WKWebView?

        var lastLoadedText: String?
        var lastAppearance: ReaderAppearanceSettings.Settings?
        var didFinishLoading = false
        var lastNavigationRequestID: UUID?
        var lastAppliedAnnotationsJSON: String?

        // Track which annotation request we last acted on
        private var lastHandledAnnotationRequestID: UUID?
        private var cancellables = Set<AnyCancellable>()

        init(_ parent: HTMLReaderView) {
            self.parent = parent
            super.init()
        }

        // ── Subscribe to ViewModel changes ───────────────────────────────
        func subscribeToViewModel() {
            let vm = parent.viewModel

            // Watch annotationApplyRequest directly on the ViewModel
            vm.$annotationApplyRequest
                .receive(on: DispatchQueue.main)
                .sink { [weak self] req in
                    guard let self, let req else { return }
                    self.handleAnnotationRequest(req)
                }
                .store(in: &cancellables)

            parent.viewModel.$annotationsNeedsReapply
                .compactMap { $0 }
                .sink { [weak self] _ in
                    self?.lastAppliedAnnotationsJSON = nil
                    self?.applyAnnotationsIfNeeded()
                }
                .store(in: &cancellables)
        }

        private func handleAnnotationRequest(_ req: MarkdownViewModel.AnnotationApplyRequest) {
            guard req.requestID != lastHandledAnnotationRequestID else { return }
            guard let webView, didFinishLoading else {
                // Page not loaded yet – nothing to do
                return
            }
            lastHandledAnnotationRequestID = req.requestID

            guard let selector = req.selector else {
                print("[Annotation] Request has no selector")
                return
            }

            let colorArg = req.colorHex != nil ? "'\(req.colorHex!)'" : "null"
            let js = "window.lightmdApplyAnnotationByOffset(\(selector.startOffset), \(selector.endOffset), '\(req.type.rawValue)', '\(req.id.uuidString)', \(colorArg))"
            print("[Annotation] Calling JS: \(js)")

            webView.evaluateJavaScript(js) { [weak self] result, error in
                guard let self else { return }
                if let error = error {
                    print("[Annotation] JS error: \(error.localizedDescription)")
                    return
                }
                guard let jsonString = result as? String,
                      let data = jsonString.data(using: .utf8),
                      let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let ok = dict["ok"] as? Bool, ok else {
                    print("[Annotation] JS returned failure: \(String(describing: result))")
                    return
                }
                print("[Annotation] Success!")
                DispatchQueue.main.async {
                    req.onSuccess()
                    // After onSuccess, the annotationStore changes → trigger redraw
                    self.lastAppliedAnnotationsJSON = nil
                    self.applyAnnotationsIfNeeded()
                }
            }
        }

        // ── Apply persisted annotations (base64-encodes JSON to avoid quote issues) ──
        func applyAnnotationsIfNeeded() {
            guard let webView, didFinishLoading else { return }
            let store = parent.annotationStore

            guard let jsonData = try? JSONEncoder().encode(store.annotations),
                  let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            guard lastAppliedAnnotationsJSON != jsonString else { return }
            lastAppliedAnnotationsJSON = jsonString

            let b64 = jsonData.base64EncodedString()
            let js = "(function(){var b=atob('\(b64)');if(typeof window.applyAnnotations==='function')window.applyAnnotations(b);})();"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        // ── WKNavigationDelegate ─────────────────────────────────────────
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            didFinishLoading = true
            applyAnnotationsIfNeeded()

            if let req = parent.viewModel.headingNavigationRequest {
                lastNavigationRequestID = req.requestID
                webView.evaluateJavaScript(
                    "var el=document.getElementById('\(req.headingID)');if(el)el.scrollIntoView({behavior:'smooth',block:'start'});",
                    completionHandler: nil)
            } else if let h = parent.viewModel.activeHeadingID {
                webView.evaluateJavaScript(
                    "var el=document.getElementById('\(h)');if(el)el.scrollIntoView({behavior:'smooth',block:'start'});",
                    completionHandler: nil)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url, url.scheme != "about" {
                // Initial loads (from loadHTMLString) have navigationType == .other but match our baseURL's base.
                // We only intercept if it's a link click or context menu "Open Link".
                if navigationAction.navigationType == .linkActivated {
                    parent.openURL(url)
                    decisionHandler(.cancel)
                    return
                } else if navigationAction.navigationType == .other {
                    // Context menu "Open Link" fires as .other on macOS.
                    // If the URL is different from our loaded baseURL (ignoring fragments), it's an external/cross-page navigation.
                    var baseComponents = parent.baseURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
                    baseComponents?.fragment = nil
                    let baseWithoutFragment = baseComponents?.url
                    
                    var targetComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    let targetFragment = targetComponents?.fragment
                    targetComponents?.fragment = nil
                    let targetWithoutFragment = targetComponents?.url
                    
                    if baseWithoutFragment != targetWithoutFragment || targetFragment != nil {
                        // Let the app handle the link (it might be a WikiLink, external link, or an anchor link)
                        // Wait, if it's an anchor link on the SAME page, and we clicked it from context menu?
                        // If it's an anchor link, the parent.openURL(url) handles it by smooth scrolling.
                        // So we should intercept it. But wait, what if it's the INITIAL load?
                        // Initial load doesn't have a fragment usually.
                        if navigationAction.targetFrame?.isMainFrame == true && url != parent.baseURL {
                            parent.openURL(url)
                            decisionHandler(.cancel)
                            return
                        }
                    }
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                parent.openURL(url)
            }
            return nil
        }

        // ── WKScriptMessageHandler ───────────────────────────────────────
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            switch message.name {
            case "contextMenuAction":
                if let dict = message.body as? [String: Any],
                   let urlStr = dict["url"] as? String,
                   let url = URL(string: urlStr),
                   let x = dict["x"] as? CGFloat,
                   let y = dict["y"] as? CGFloat {
                    
                    let menu = NSMenu()
                    let openRight = NSMenuItem(title: "오른쪽 창에서 열기", action: #selector(openRightPage(_:)), keyEquivalent: "")
                    openRight.representedObject = url
                    openRight.target = self
                    menu.addItem(openRight)
                    
                    if let webView = self.webView {
                        // JS coordinates are from top-left, NSView coordinates are from bottom-left
                        let nsY = webView.bounds.height - y
                        menu.popUp(positioning: nil, at: NSPoint(x: x, y: nsY), in: webView)
                    }
                }
            case "textSelection":
                if let dict = message.body as? [String: Any],
                   let exact = dict["exact"] as? String,
                   let startOffset = dict["startOffset"] as? Int,
                   let endOffset = dict["endOffset"] as? Int {
                    let selector = TextAnnotationSelector(
                        exact: exact,
                        prefix: dict["prefix"] as? String,
                        suffix: dict["suffix"] as? String,
                        startOffset: startOffset,
                        endOffset: endOffset
                    )
                    DispatchQueue.main.async {
                        self.parent.viewModel.currentSelectedText = exact
                        self.parent.viewModel.currentSelectionSelector = selector
                        self.parent.viewModel.hasTextSelection = true
                        self.parent.viewModel.activeAnnotationID = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.viewModel.currentSelectedText = ""
                        self.parent.viewModel.currentSelectionSelector = nil
                        self.parent.viewModel.hasTextSelection = false
                    }
                }

            case "annotationClicked":
                if let idStr = message.body as? String, let uuid = UUID(uuidString: idStr) {
                    DispatchQueue.main.async {
                        self.parent.viewModel.activeAnnotationID = uuid
                        self.parent.viewModel.hasTextSelection = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.parent.viewModel.activeAnnotationID = nil
                    }
                }

            case "debugLog":
                if let msg = message.body as? String {
                    print("[WebView] \(msg)")
                }

            default:
                break
            }
        }

        @objc func openRightPage(_ sender: NSMenuItem) {
            if let url = sender.representedObject as? URL {
                parent.viewModel.openInRightPane(url)
            }
        }

        private func applyColorToSelection(_ hex: String) {
            let id = UUID()
            let typeStr: AnnotationType = parent.viewModel.hasTextSelection ? .textColor : .underline
            let req = MarkdownViewModel.AnnotationApplyRequest(
                id: id,
                type: typeStr,
                selector: parent.viewModel.currentSelectionSelector,
                colorHex: hex,
                onSuccess: {
                    self.parent.viewModel.hasTextSelection = false
                }
            )
            parent.viewModel.annotationApplyRequest = req
        }
}
}
