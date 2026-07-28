import Foundation

struct DocumentStatistics: Equatable {
    let wordCount: Int
    let charCount: Int
    let readingTimeMinutes: Int
    
    static let empty = DocumentStatistics(wordCount: 0, charCount: 0, readingTimeMinutes: 0)
    
    static func calculate(from text: String) -> DocumentStatistics {
        let chars = text.count
        
        // Approximate words by splitting on whitespaces and newlines
        // A simple but fast heuristic for Markdown
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        
        // Average reading speed: 200 words per minute
        let minutes = max(1, Int(ceil(Double(words) / 200.0)))
        
        return DocumentStatistics(
            wordCount: words,
            charCount: chars,
            readingTimeMinutes: minutes
        )
    }
}
