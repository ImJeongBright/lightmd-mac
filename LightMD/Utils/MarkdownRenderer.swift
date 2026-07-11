import SwiftUI

struct MarkdownBlock: Identifiable, Hashable {
    enum Kind: Hashable {
        case heading(level: Int, text: String, id: String)
        case paragraph(String)
        case unorderedList([MarkdownListItem])
        case orderedList([String])
        case taskList([MarkdownTaskItem])
        case quote(String)
        case code(language: String?, text: String)
        case table(MarkdownTable)
        case divider
    }

    let id: String
    let kind: Kind
    let rawText: String
    let contentHash: String
}

struct MarkdownListItem: Identifiable, Hashable {
    let id: String
    let text: String

    init(text: String, index: Int) {
        self.id = "list-item-\(index)-\(MarkdownRenderer.shortHash(text))"
        self.text = text
    }
}

struct MarkdownTaskItem: Identifiable, Hashable {
    let id: String
    let text: String
    let isChecked: Bool

    init(text: String, isChecked: Bool, index: Int) {
        self.id = "task-item-\(index)-\(MarkdownRenderer.shortHash(text))"
        self.text = text
        self.isChecked = isChecked
    }
}

struct MarkdownTable: Hashable {
    let headers: [String]
    let rows: [[String]]

    var columnCount: Int {
        max(headers.count, rows.map(\.count).max() ?? 0)
    }
}

enum MarkdownRenderer {
    static func parse(_ markdown: String) -> [MarkdownBlock] {
        let normalized = markdown.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var index = 0
        var headingIndex = 0
        var blockIndex = 0

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                index += 1
                continue
            }

            if let fence = codeFence(in: trimmed) {
                let language = trimmed.dropFirst(fence.count).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                index += 1

                while index < lines.count {
                    let currentLine = lines[index]
                    let currentTrimmed = currentLine.trimmingCharacters(in: .whitespaces)

                    if currentTrimmed.hasPrefix(fence) {
                        index += 1
                        break
                    }

                    codeLines.append(currentLine)
                    index += 1
                }

                let rawText = codeLines.joined(separator: "\n")
                blocks.append(makeBlock(
                    kind: .code(
                    language: language.isEmpty ? nil : language,
                    text: rawText
                    ),
                    rawText: rawText,
                    index: blockIndex
                ))
                blockIndex += 1
                continue
            }

            if let table = parseTable(startingAt: index, lines: lines) {
                blocks.append(makeBlock(
                    kind: .table(table.value),
                    rawText: table.rawText,
                    index: blockIndex
                ))
                blockIndex += 1
                index = table.nextIndex
                continue
            }

            if let heading = parseHeading(from: trimmed) {
                let id = headingID(for: heading.text, index: headingIndex)
                blocks.append(makeBlock(
                    kind: .heading(level: heading.level, text: heading.text, id: id),
                    rawText: trimmed,
                    index: blockIndex
                ))
                headingIndex += 1
                blockIndex += 1
                index += 1
                continue
            }

            if isDivider(trimmed) {
                blocks.append(makeBlock(kind: .divider, rawText: trimmed, index: blockIndex))
                blockIndex += 1
                index += 1
                continue
            }

            if isBlockquote(trimmed) {
                var quoteLines: [String] = []

                while index < lines.count {
                    let currentLine = lines[index]
                    let currentLeadingTrimmed = String(currentLine.drop(while: { $0.isWhitespace }))

                    guard isBlockquote(currentLeadingTrimmed) else {
                        break
                    }

                    quoteLines.append(stripBlockquoteMarker(from: currentLeadingTrimmed))
                    index += 1
                }

                let rawText = quoteLines.joined(separator: "\n")
                blocks.append(makeBlock(kind: .quote(rawText), rawText: rawText, index: blockIndex))
                blockIndex += 1
                continue
            }

            if let firstTask = parseTaskItem(from: trimmed) {
                var items = [firstTask]
                var itemIndex = 1
                index += 1

                while index < lines.count {
                    let currentTrimmed = lines[index].trimmingCharacters(in: .whitespaces)

                    guard let item = parseTaskItem(from: currentTrimmed, index: itemIndex) else {
                        break
                    }

                    items.append(item)
                    itemIndex += 1
                    index += 1
                }

                let rawText = items.map(\.text).joined(separator: "\n")
                blocks.append(makeBlock(kind: .taskList(items), rawText: rawText, index: blockIndex))
                blockIndex += 1
                continue
            }

            if let firstListItem = parseUnorderedItem(from: trimmed) {
                var items = [MarkdownListItem(text: firstListItem, index: 0)]
                var itemIndex = 1
                index += 1

                while index < lines.count {
                    let currentTrimmed = lines[index].trimmingCharacters(in: .whitespaces)

                    guard let item = parseUnorderedItem(from: currentTrimmed) else {
                        break
                    }

                    items.append(MarkdownListItem(text: item, index: itemIndex))
                    itemIndex += 1
                    index += 1
                }

                let rawText = items.map(\.text).joined(separator: "\n")
                blocks.append(makeBlock(kind: .unorderedList(items), rawText: rawText, index: blockIndex))
                blockIndex += 1
                continue
            }

            if let firstOrderedItem = parseOrderedItem(from: trimmed) {
                var items = [firstOrderedItem]
                index += 1

                while index < lines.count {
                    let currentTrimmed = lines[index].trimmingCharacters(in: .whitespaces)

                    guard let item = parseOrderedItem(from: currentTrimmed) else {
                        break
                    }

                    items.append(item)
                    index += 1
                }

                let rawText = items.joined(separator: "\n")
                blocks.append(makeBlock(kind: .orderedList(items), rawText: rawText, index: blockIndex))
                blockIndex += 1
                continue
            }

            var paragraphLines = [trimmed]
            index += 1

            while index < lines.count {
                let currentTrimmed = lines[index].trimmingCharacters(in: .whitespaces)

                if currentTrimmed.isEmpty || isBlockStarter(currentTrimmed) {
                    break
                }

                paragraphLines.append(currentTrimmed)
                index += 1
            }

            let rawText = paragraphLines.joined(separator: "\n")
            blocks.append(makeBlock(kind: .paragraph(rawText), rawText: rawText, index: blockIndex))
            blockIndex += 1
        }

        return blocks
    }

    static func extractHeadings(_ markdown: String, maxLevel: Int = 3) -> [MarkdownHeading] {
        parse(markdown)
            .compactMap { block -> MarkdownHeading? in
                guard case let .heading(level, text, id) = block.kind,
                      level <= maxLevel else {
                    return nil
                }

                return MarkdownHeading(id: id, level: level, title: text, index: 0)
            }
            .enumerated()
            .map { index, heading in
                MarkdownHeading(id: heading.id, level: heading.level, title: heading.title, index: index)
            }
    }

    static func inline(
        _ text: String,
        baseColor: Color? = nil,
        codeBackground: Color? = nil
    ) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )

        do {
            var attributed = try AttributedString(markdown: text, options: options)
            styleInlineRuns(&attributed, baseColor: baseColor, codeBackground: codeBackground)
            return attributed
        } catch {
            return AttributedString(text)
        }
    }

    private static func isBlockStarter(_ line: String) -> Bool {
        codeFence(in: line) != nil ||
            parseHeading(from: line) != nil ||
            isDivider(line) ||
            isBlockquote(line) ||
            parseTaskItem(from: line) != nil ||
            parseTable(startingAt: 0, lines: [line, ""]) != nil ||
            parseUnorderedItem(from: line) != nil ||
            parseOrderedItem(from: line) != nil
    }

    private static func codeFence(in line: String) -> String? {
        if line.hasPrefix("```") {
            return "```"
        }

        if line.hasPrefix("~~~") {
            return "~~~"
        }

        return nil
    }

    private static func parseHeading(from line: String) -> (level: Int, text: String)? {
        var level = 0

        for character in line {
            if character == "#" {
                level += 1
            } else {
                break
            }
        }

        guard (1...6).contains(level) else {
            return nil
        }

        let markerEnd = line.index(line.startIndex, offsetBy: level)
        guard markerEnd < line.endIndex, line[markerEnd].isWhitespace else {
            return nil
        }

        let textStart = line.index(after: markerEnd)
        let text = String(line[textStart...]).trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : (level, text)
    }

    private static func isDivider(_ line: String) -> Bool {
        guard line.count >= 3 else {
            return false
        }

        let withoutSpaces = line.replacingOccurrences(of: " ", with: "")
        guard withoutSpaces.count >= 3 else {
            return false
        }

        let characters = Set(withoutSpaces)
        return characters == ["-"] || characters == ["*"] || characters == ["_"]
    }

    private static func isBlockquote(_ line: String) -> Bool {
        line.hasPrefix(">")
    }

    private static func stripBlockquoteMarker(from line: String) -> String {
        let withoutMarker = String(line.dropFirst())
        return withoutMarker.hasPrefix(" ") ? String(withoutMarker.dropFirst()) : withoutMarker
    }

    private static func parseTaskItem(from line: String, index: Int = 0) -> MarkdownTaskItem? {
        guard let itemText = parseUnorderedItem(from: line), itemText.count >= 4 else {
            return nil
        }

        let lowercased = itemText.lowercased()

        if lowercased.hasPrefix("[ ] ") {
            let text = String(itemText.dropFirst(4))
            return MarkdownTaskItem(text: text, isChecked: false, index: index)
        }

        if lowercased.hasPrefix("[x] ") {
            let text = String(itemText.dropFirst(4))
            return MarkdownTaskItem(text: text, isChecked: true, index: index)
        }

        return nil
    }

    private static func parseUnorderedItem(from line: String) -> String? {
        for marker in ["- ", "* ", "+ "] {
            if line.hasPrefix(marker) {
                return String(line.dropFirst(marker.count))
            }
        }

        return nil
    }

    private static func parseOrderedItem(from line: String) -> String? {
        let characters = Array(line)
        var digitCount = 0

        while digitCount < characters.count, characters[digitCount].isNumber {
            digitCount += 1
        }

        guard digitCount > 0,
              digitCount + 1 < characters.count,
              characters[digitCount] == "." || characters[digitCount] == ")",
              characters[digitCount + 1].isWhitespace else {
            return nil
        }

        return String(characters.dropFirst(digitCount + 2))
    }

    private static func parseTable(
        startingAt index: Int,
        lines: [String]
    ) -> (value: MarkdownTable, rawText: String, nextIndex: Int)? {
        guard index + 1 < lines.count else {
            return nil
        }

        let headerLine = lines[index].trimmingCharacters(in: .whitespaces)
        let separatorLine = lines[index + 1].trimmingCharacters(in: .whitespaces)

        guard headerLine.contains("|"),
              separatorLine.contains("|"),
              isTableSeparator(separatorLine) else {
            return nil
        }

        let headers = parseTableCells(headerLine)
        guard !headers.isEmpty else {
            return nil
        }

        var tableLines = [headerLine, separatorLine]
        var rows: [[String]] = []
        var currentIndex = index + 2

        while currentIndex < lines.count {
            let line = lines[currentIndex].trimmingCharacters(in: .whitespaces)

            guard line.contains("|"), !line.isEmpty else {
                break
            }

            rows.append(parseTableCells(line))
            tableLines.append(line)
            currentIndex += 1
        }

        return (
            MarkdownTable(headers: headers, rows: rows),
            tableLines.joined(separator: "\n"),
            currentIndex
        )
    }

    private static func isTableSeparator(_ line: String) -> Bool {
        let cells = parseTableCells(line)

        guard !cells.isEmpty else {
            return false
        }

        return cells.allSatisfy { cell in
            let trimmed = cell.trimmingCharacters(in: .whitespaces)
            let body = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
            return body.count >= 3 && body.allSatisfy { $0 == "-" }
        }
    }

    private static func parseTableCells(_ line: String) -> [String] {
        var normalized = line.trimmingCharacters(in: .whitespaces)

        if normalized.hasPrefix("|") {
            normalized.removeFirst()
        }

        if normalized.hasSuffix("|") {
            normalized.removeLast()
        }

        return normalized
            .split(separator: "|", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespaces) }
    }

    private static func headingID(for title: String, index: Int) -> String {
        let slug = anchorSlug(for: title)

        return "heading-\(index)-\(slug.isEmpty ? "section" : slug)"
    }

    static func anchorSlug(for title: String) -> String {
        title
            .lowercased()
            .unicodeScalars
            .map { scalar -> String in
                CharacterSet.alphanumerics.contains(scalar) ? String(scalar) : "-"
            }
            .joined()
            .split(separator: "-")
            .joined(separator: "-")
    }

    static func shortHash(_ text: String) -> String {
        var hash: UInt64 = 5381

        for scalar in text.unicodeScalars {
            hash = ((hash << 5) &+ hash) &+ UInt64(scalar.value)
        }

        return String(hash, radix: 16)
    }

    private static func makeBlock(kind: MarkdownBlock.Kind, rawText: String, index: Int) -> MarkdownBlock {
        let contentHash = shortHash(rawText)
        return MarkdownBlock(
            id: "block-\(index)-\(contentHash)",
            kind: kind,
            rawText: rawText,
            contentHash: contentHash
        )
    }

    private static func styleInlineRuns(
        _ attributed: inout AttributedString,
        baseColor: Color?,
        codeBackground: Color?
    ) {
        for run in attributed.runs {
            if let baseColor, run.link == nil {
                attributed[run.range].foregroundColor = baseColor
            }

            if run.link != nil {
                attributed[run.range].foregroundColor = .accentColor
                attributed[run.range].underlineStyle = .single
            }

            if run.inlinePresentationIntent?.contains(.code) == true {
                attributed[run.range].font = .system(size: 14, design: .monospaced)

                if let codeBackground {
                    attributed[run.range].backgroundColor = codeBackground
                }
            }
        }
    }
}
