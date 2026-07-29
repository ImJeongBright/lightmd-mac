import Foundation

enum GitStatus: String, Equatable {
    case modified = "M"
    case added = "A"
    case deleted = "D"
    case untracked = "??"
    case normal = ""
}

final class GitStatusService {
    
    /// Returns a dictionary mapping relative file paths to their GitStatus
    static func getStatus(for folderURL: URL) -> [String: GitStatus] {
        guard isGitRepository(at: folderURL) else { return [:] }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["status", "--porcelain"]
        process.currentDirectoryURL = folderURL
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return [:] }
            
            var statusMap: [String: GitStatus] = [:]
            
            let lines = output.components(separatedBy: .newlines)
            for line in lines where line.count > 3 {
                let statusStr = String(line.prefix(2)).trimmingCharacters(in: .whitespaces)
                // strip quotes if any
                var relativePath = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                if relativePath.hasPrefix("\"") && relativePath.hasSuffix("\"") {
                    relativePath = String(relativePath.dropFirst().dropLast())
                }
                
                let status: GitStatus
                switch statusStr {
                case "M", "AM", "MM": status = .modified
                case "A": status = .added
                case "D": status = .deleted
                case "??": status = .untracked
                default: status = .modified
                }
                
                statusMap[relativePath] = status
            }
            
            return statusMap
        } catch {
            return [:]
        }
    }
    
    static func isGitRepository(at url: URL) -> Bool {
        let gitFolder = url.appendingPathComponent(".git")
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: gitFolder.path, isDirectory: &isDir) {
            return isDir.boolValue || FileManager.default.fileExists(atPath: gitFolder.path)
        }
        return false
    }
    
    static func getDiff(for fileURL: URL, in workspaceURL: URL) -> String? {
        guard isGitRepository(at: workspaceURL) else { return nil }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["diff", "HEAD", "--", fileURL.path]
        process.currentDirectoryURL = workspaceURL
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                return output
            }
            
            // If empty, it might be an untracked file or newly added without commits yet.
            // Let's try git diff without HEAD just in case it's staged
            let stagedProcess = Process()
            stagedProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            stagedProcess.arguments = ["diff", "--cached", "--", fileURL.path]
            stagedProcess.currentDirectoryURL = workspaceURL
            
            let stagedPipe = Pipe()
            stagedProcess.standardOutput = stagedPipe
            try stagedProcess.run()
            stagedProcess.waitUntilExit()
            
            let stagedData = stagedPipe.fileHandleForReading.readDataToEndOfFile()
            if let stagedOutput = String(data: stagedData, encoding: .utf8), !stagedOutput.isEmpty {
                return stagedOutput
            }
            
            return nil
        } catch {
            return nil
        }
    }
}
