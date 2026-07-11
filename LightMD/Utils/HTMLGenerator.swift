import Foundation
import SwiftUI

enum HTMLGenerator {
    static func generateHTML(from blocks: [MarkdownBlock], appearance: ReaderAppearanceSettings.Settings = ReaderAppearanceSettings.Settings()) -> String {
        let css = generateCSS(for: appearance)

        var html = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.min.css\">\n<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js\"></script>\n\(css)\n</head>\n<body>\n"

        for block in blocks {
            let blockID = block.id
            let idAttr = "data-block-id=\"\(blockID)\""

            switch block.kind {
            case let .heading(level, text, id):
                html += "<h\(level) id=\"\(id)\" \(idAttr)>\(parseInline(text))</h\(level)>\n"
            case let .paragraph(text):
                html += "<p \(idAttr)>\(parseInline(text))</p>\n"
            case let .quote(text):
                html += "<blockquote \(idAttr)>\(parseInline(text))</blockquote>\n"
            case let .code(language, text):
                html += "<pre \(idAttr)><code\(language != nil ? " class=\"language-\(language!)\"" : "")>\(escapeHTML(text))</code></pre>\n"
            case .divider:
                html += "<hr \(idAttr)>\n"
            case let .unorderedList(items):
                html += "<ul \(idAttr)>\n"
                for item in items { html += "<li>\(parseInline(item.text))</li>\n" }
                html += "</ul>\n"
            case let .orderedList(items):
                html += "<ol \(idAttr)>\n"
                for item in items { html += "<li>\(parseInline(item))</li>\n" }
                html += "</ol>\n"
            case let .taskList(items):
                html += "<ul \(idAttr) style=\"padding-left: 10px;\">\n"
                for item in items {
                    let checked = item.isChecked ? "checked" : ""
                    html += "<li class=\"task-list-item\"><input type=\"checkbox\" \(checked) disabled> \(parseInline(item.text))</li>\n"
                }
                html += "</ul>\n"
            case let .table(table):
                html += "<table \(idAttr)>\n<thead><tr>\n"
                for header in table.headers { html += "<th>\(parseInline(header))</th>\n" }
                html += "</tr></thead>\n<tbody>\n"
                for row in table.rows {
                    html += "<tr>\n"
                    for i in 0..<table.columnCount {
                        let cell = i < row.count ? row[i] : ""
                        html += "<td>\(parseInline(cell))</td>\n"
                    }
                    html += "</tr>\n"
                }
                html += "</tbody>\n</table>\n"
            }
        }

        html += annotationJS
        html += "<script>hljs.highlightAll();</script>\n"
        html += "</body>\n</html>"
        return html
    }

    private static func generateCSS(for app: ReaderAppearanceSettings.Settings) -> String {
        // Theme Colors
        // Define color palettes
        let lightVars = """
            --text-color: #333333;
            --bg-color: transparent;
            --link-color: #0066cc;
            --code-bg: #f5f5f5;
            --border-color: #e0e0e0;
            --quote-border: #0066cc;
            --quote-bg: #f9f9f9;
            --highlight-bg: rgba(255, 214, 10, 0.35);
            --underline-color: rgba(200, 130, 20, 0.9);
            --memo-bg: rgba(90, 200, 120, 0.2);
        """
        
        let darkVars = """
            --text-color: #e0e0e0;
            --bg-color: transparent;
            --link-color: #4da6ff;
            --code-bg: #2d2d2d;
            --border-color: #404040;
            --quote-border: #4da6ff;
            --quote-bg: #2a2a2a;
            --highlight-bg: rgba(255, 214, 10, 0.25);
            --underline-color: rgba(220, 160, 40, 0.9);
            --memo-bg: rgba(90, 200, 120, 0.15);
        """
        
        let sepiaVars = """
            --text-color: #433422;
            --bg-color: #f4ecd8;
            --link-color: #b35900;
            --code-bg: #eaddc2;
            --border-color: #d8c3a5;
            --quote-border: #b35900;
            --quote-bg: #eaddc2;
            --highlight-bg: rgba(255, 214, 10, 0.45);
            --underline-color: rgba(200, 130, 20, 0.9);
            --memo-bg: rgba(90, 200, 120, 0.2);
        """
        
        let solarizedVars = """
            --text-color: #839496;
            --bg-color: #002b36;
            --link-color: #268bd2;
            --code-bg: #073642;
            --border-color: #586e75;
            --quote-border: #2aa198;
            --quote-bg: #073642;
            --highlight-bg: rgba(181, 137, 0, 0.35);
            --underline-color: rgba(203, 75, 22, 0.9);
            --memo-bg: rgba(133, 153, 0, 0.2);
        """
        
        let themeVars: String
        let darkThemeVars: String
        
        switch app.documentTheme {
        case .light:
            themeVars = lightVars
            darkThemeVars = lightVars // override media query
        case .dark:
            themeVars = darkVars
            darkThemeVars = darkVars
        case .sepia:
            themeVars = sepiaVars
            darkThemeVars = sepiaVars
        case .solarizedDark:
            themeVars = solarizedVars
            darkThemeVars = solarizedVars
        case .system:
            themeVars = lightVars
            darkThemeVars = darkVars
        }
        
        let css = """
        <style>
            :root {
                color-scheme: light dark;
                \(themeVars)
            }
            @media (prefers-color-scheme: dark) {
                :root {
                    \(darkThemeVars)
                }
            }
            body {
                font-family: \(app.fontFamily.cssValue);
                color: var(--text-color);
                background-color: var(--bg-color);
                line-height: \(app.lineSpacing.cssValue);
                padding: 20px 40px;
                margin: 0 auto;
                max-width: \(app.contentWidth.cssValue);
                font-size: \(app.fontSizeBase)px;
                transition: background-color 0.3s, color 0.3s;
            }
            a { color: var(--link-color); text-decoration: none; }
            a:hover { text-decoration: underline; }
            p, h1, h2, h3, h4, h5, h6, ul, ol, pre, blockquote, table {
                margin-top: 0;
                margin-bottom: \(app.fontSizeBase + 2)px;
            }
            p { margin-bottom: \(app.fontSizeBase)px; }
            h1 { font-size: 2em; margin-top: 24px; font-weight: 700; }
            h2 { font-size: 1.5em; margin-top: 20px; font-weight: 600; }
            h3 { font-size: 1.25em; margin-top: 16px; font-weight: 600; }
            code {
                font-family: ui-monospace, SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
                background-color: var(--code-bg);
                padding: 0.2em 0.4em;
                border-radius: 4px;
                font-size: 0.9em;
            }
            pre {
                background-color: var(--code-bg);
                padding: 16px;
                overflow: auto;
                border: 1px solid var(--border-color);
                border-radius: 6px;
            }
            pre code { background-color: transparent; padding: 0; }
            blockquote {
                border-left: 4px solid var(--quote-border);
                background-color: var(--quote-bg);
                padding: 10px 16px;
                margin-left: 0;
                margin-right: 0;
                border-radius: 0 6px 6px 0;
            }
            table { border-collapse: collapse; width: 100%; display: block; overflow: auto; }
            th, td { border: 1px solid var(--border-color); padding: 8px 12px; }
            th { background-color: var(--code-bg); font-weight: 600; text-align: left; }
            hr { border: 0; border-bottom: 1px solid var(--border-color); margin: 24px 0; }
            .task-list-item { list-style-type: none; display: flex; align-items: center; gap: 8px; }
            .task-list-item input { margin: 0; }
            ul, ol { padding-left: 30px; }

            /* ── Annotation styles ── */
            .annotation-highlight { background-color: var(--highlight-bg); border-radius: 2px; }
            .annotation-underline { border-bottom: 2px solid var(--underline-color); }
            .annotation-memo      { background-color: var(--memo-bg); border-radius: 2px; }
        </style>
        """
        return css
    }

    // MARK: - JavaScript

    private static let annotationJS = """
    <script>
    // ═══════════════════════════════════════════════════════════════
    // 1. TEXT NODE UTILITIES
    // ═══════════════════════════════════════════════════════════════

    function getAllTextNodes() {
        var w = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        var ns = [];
        while (w.nextNode()) ns.push(w.currentNode);
        return ns;
    }

    // Resolve a DOM Range boundary (container, offset) → {node, offset}
    // where node is always a TEXT_NODE.
    function resolveToText(container, off) {
        if (container.nodeType === 3) return {node: container, offset: off};
        var ch = container.childNodes;
        if (off < ch.length) {
            var w = document.createTreeWalker(ch[off], NodeFilter.SHOW_TEXT, null, false);
            var f = w.nextNode();
            if (f) return {node: f, offset: 0};
        }
        // After all children – find last text node inside container
        var w2 = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, null, false);
        var last = null;
        while (w2.nextNode()) last = w2.currentNode;
        return last ? {node: last, offset: last.nodeValue.length} : null;
    }

    // Turn (textNode, charOffset) → absolute character index in body
    function absOffset(targetNode, charOff) {
        var pos = 0;
        var w = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        while (w.nextNode()) {
            if (w.currentNode === targetNode) return pos + charOff;
            pos += w.currentNode.nodeValue.length;
        }
        return -1;
    }

    // ═══════════════════════════════════════════════════════════════
    // 2. SELECTION → SWIFT  (offsets survive focus loss)
    // ═══════════════════════════════════════════════════════════════

    var _ss = -1, _se = -1, _selTimer = null;

    function reportSelection() {
        var sel = window.getSelection();
        if (!sel || sel.isCollapsed || !sel.rangeCount) {
            _ss = -1; _se = -1;
            if (window.webkit && window.webkit.messageHandlers.textSelection)
                window.webkit.messageHandlers.textSelection.postMessage(null);
            return;
        }
        var r  = sel.getRangeAt(0);
        var sr = resolveToText(r.startContainer, r.startOffset);
        var er = resolveToText(r.endContainer,   r.endOffset);
        if (!sr || !er) return;
        var sa = absOffset(sr.node, sr.offset);
        var ea = absOffset(er.node, er.offset);
        if (sa < 0 || ea <= sa) return;

        _ss = sa; _se = ea;

        var body = document.body.textContent;
        var exact = sel.toString();
        if (exact.length > 300) exact = exact.substring(0,300) + '...';

        if (window.webkit && window.webkit.messageHandlers.textSelection)
            window.webkit.messageHandlers.textSelection.postMessage({
                exact: exact,
                prefix: body.substring(Math.max(0, sa-20), sa),
                suffix: body.substring(ea, Math.min(body.length, ea+20)),
                startOffset: sa,
                endOffset: ea
            });
    }

    document.addEventListener('mouseup', reportSelection);
    document.addEventListener('keyup', function(){
        clearTimeout(_selTimer);
        _selTimer = setTimeout(reportSelection, 80);
    });
    document.addEventListener('selectionchange', function() {
        var sel = window.getSelection();
        if (!sel || sel.isCollapsed || !sel.rangeCount) return;
        var r = sel.getRangeAt(0);
        var getBlock = function(node) {
            if (!node) return null;
            var el = node.nodeType === 3 ? node.parentNode : node;
            return el.closest ? el.closest('pre, table') : null;
        };
        if (getBlock(r.startContainer) !== getBlock(r.endContainer)) {
            sel.removeAllRanges();
            reportSelection();
        }
    });

    // ═══════════════════════════════════════════════════════════════
    // 3. ANNOTATION CLICK
    // ═══════════════════════════════════════════════════════════════

    document.addEventListener('click', function(e){
        var sp = e.target.closest('span[data-annotation-id]');
        if (window.webkit && window.webkit.messageHandlers.annotationClicked)
            window.webkit.messageHandlers.annotationClicked.postMessage(
                sp ? sp.getAttribute('data-annotation-id') : null);
    });

    // ═══════════════════════════════════════════════════════════════
    // 4. WRAP TEXT RANGE  [startAbs, endAbs)
    //
    // 4. APPLY ANNOTATIONS
    // ═══════════════════════════════════════════════════════════════

    function wrapTextRange(sa, ea, type, annId, colorHex) {
        document.body.normalize();
        var ns = getAllTextNodes();
        var pos = 0;
        var sI = -1, sO = 0, eI = -1, eO = 0;
        for (var i = 0; i < ns.length; i++) {
            var len = ns[i].nodeValue.length;
            if (sI < 0 && pos + len > sa) { sI = i; sO = sa - pos; }
            if (eI < 0 && pos + len >= ea) { eI = i; eO = ea - pos; break; }
            pos += len;
        }
        if (sI < 0 || eI < 0)
            return JSON.stringify({ok:false, reason:'NOT_FOUND', sa:sa, ea:ea, count:ns.length});

        var eNode = ns[eI], sNode = ns[sI];

        // Split end first so start index remains valid
        if (eO < eNode.nodeValue.length) eNode.splitText(eO);

        if (sO > 0) {
            sNode = sNode.splitText(sO);   // sNode is now the highlighted part
            if (sI === eI) eNode = sNode;  // same-node: eNode is also this new piece
        }

        // Fresh node list after splits
        var fresh = getAllTextNodes();
        var fi = fresh.indexOf(sNode);
        var fj = fresh.indexOf(eNode);
        if (fi < 0 || fj < 0 || fi > fj)
            return JSON.stringify({ok:false, reason:'LOST', fi:fi, fj:fj});

        for (var k = fi; k <= fj; k++) {
            var tn = fresh[k];
            if (!tn.nodeValue) continue;
            if (tn.parentNode && tn.parentNode.nodeName === 'SPAN' &&
                tn.parentNode.getAttribute('data-annotation-id') === annId) continue;
            var span = document.createElement('span');
            span.setAttribute('data-annotation-id', annId);
            span.className = 'annotation-' + type;
            if (colorHex) {
                span.style.color = colorHex;
            }
            tn.parentNode.insertBefore(span, tn);
            span.appendChild(tn);
        }
        return JSON.stringify({ok:true});
    }

    // ═══════════════════════════════════════════════════════════════
    // 5. PUBLIC API  (called from Swift via evaluateJavaScript)
    // ═══════════════════════════════════════════════════════════════

    window.lightmdApplyAnnotationByOffset = function(sa, ea, type, annId, colorHex) {
        var r = wrapTextRange(sa, ea, type, annId, colorHex);
        if (window.webkit && window.webkit.messageHandlers.debugLog)
            window.webkit.messageHandlers.debugLog.postMessage(
                'applyByOffset ' + sa + '-' + ea + ' type=' + type + ' => ' + r);
        return r;
    };

    window.lightmdApplyAnnotationToSavedRange = function(type, annId, colorHex) {
        if (_ss < 0 || _se <= _ss)
            return JSON.stringify({ok:false, reason:'NO_SAVED_RANGE', ss:_ss, se:_se});
        var s = _ss, e = _se;
        _ss = -1; _se = -1;
        return wrapTextRange(s, e, type, annId, colorHex);
    };

    window.applyAnnotations = function(json) {
        document.querySelectorAll('span[data-annotation-id]').forEach(function(sp){
            while (sp.firstChild) sp.parentNode.insertBefore(sp.firstChild, sp);
            sp.parentNode.removeChild(sp);
        });
        document.body.normalize();
        var anns;
        try { anns = JSON.parse(json); } catch(e) { return; }
        anns.sort(function(a,b){ return b.selector.startOffset - a.selector.startOffset; });
        for (var i = 0; i < anns.length; i++)
            wrapTextRange(anns[i].selector.startOffset, anns[i].selector.endOffset,
                          anns[i].type, anns[i].id, anns[i].colorHex);
    };
    document.addEventListener('contextmenu', function(e) {
        var a = e.target.closest('a');
        if (a && a.href) {
            e.preventDefault();
            if (window.webkit && window.webkit.messageHandlers.contextMenuAction) {
                window.webkit.messageHandlers.contextMenuAction.postMessage({
                    url: a.href,
                    x: e.clientX,
                    y: e.clientY
                });
            }
        }
    });

    </script>
    """

    // MARK: - Inline Markdown

    private static func parseInline(_ text: String) -> String {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        do {
            let attributed = try AttributedString(markdown: text, options: options)
            var html = ""
            for run in attributed.runs {
                let textRun = String(attributed[run.range].characters)
                var escaped = escapeHTML(textRun)
                let isCode = run.inlinePresentationIntent?.contains(.code) == true
                if !isCode { 
                    escaped = processWikiLinks(in: escaped)
                    escaped = escaped.replacingOccurrences(of: "\n", with: "<br>")
                }

                var prefix = ""
                var suffix = ""
                if let link = run.link {
                    prefix += "<a href=\"\(link.absoluteString)\">"
                    suffix = "</a>" + suffix
                }
                if let intent = run.inlinePresentationIntent {
                    if intent.contains(.code)              { prefix += "<code>";   suffix = "</code>"   + suffix }
                    if intent.contains(.stronglyEmphasized){ prefix += "<strong>"; suffix = "</strong>" + suffix }
                    if intent.contains(.emphasized)        { prefix += "<em>";     suffix = "</em>"     + suffix }
                    if intent.contains(.strikethrough)     { prefix += "<del>";    suffix = "</del>"    + suffix }
                }
                html += prefix + escaped + suffix
            }
            return html
        } catch {
            return escapeHTML(text)
        }
    }

    private static func escapeHTML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private static func processWikiLinks(in text: String) -> String {
        let pattern = "\\[\\[(.*?)\\]\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return text }
        var result = text
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: nsRange).reversed()
        for match in matches {
            guard let range     = Range(match.range(at: 1), in: text),
                  let fullRange = Range(match.range, in: text) else { continue }
            let content = String(text[range])
            let parts = content.split(separator: "|", maxSplits: 1).map(String.init)
            let target = parts[0]
            let alias  = parts.count > 1 ? parts[1] : target
            var pathPart   = target
            var anchorPart = ""
            if let hashIndex = target.firstIndex(of: "#") {
                anchorPart = String(target[hashIndex...])
                pathPart   = String(target[..<hashIndex])
            }
            let encodedPath   = pathPart.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? pathPart
            let encodedAnchor = anchorPart.isEmpty ? "" :
                "#" + (String(anchorPart.dropFirst()).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String(anchorPart.dropFirst()))
            let link = "<a href=\"lightmd-wikilink://\(encodedPath)\(encodedAnchor)\" class=\"lightmd-wikilink\">\(alias)</a>"
            result.replaceSubrange(fullRange, with: link)
        }
        return result
    }
}
