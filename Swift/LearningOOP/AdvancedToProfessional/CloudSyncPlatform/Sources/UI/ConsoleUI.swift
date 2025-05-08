import Foundation
import Rainbow

/// Console UI Manager - Handles console UI rendering
class ConsoleUI {
    // MARK: - Singleton
    
    static let shared = ConsoleUI()
    
    // MARK: - Properties
    
    private let screenWidth: Int
    
    // MARK: - Initialization
    
    private init() {
        // Determine terminal width
        if let columns = ProcessInfo.processInfo.environment["COLUMNS"],
           let width = Int(columns) {
            self.screenWidth = width
        } else {
            // Default width if terminal width cannot be determined
            self.screenWidth = 80
        }
    }
    
    // MARK: - UI Methods
    
    /// Print a header
    /// - Parameter title: Header title
    func printHeader(_ title: String) {
        let line = String(repeating: "=", count: min(title.count + 4, screenWidth))
        print("\n\(line)".cyan.bold)
        print("| \(title) |".cyan.bold)
        print("\(line)\n".cyan.bold)
    }
    
    /// Print a subheader
    /// - Parameter title: Subheader title
    func printSubheader(_ title: String) {
        let line = String(repeating: "-", count: min(title.count + 4, screenWidth))
        print("\n\(line)".yellow)
        print("| \(title) |".yellow)
        print("\(line)\n".yellow)
    }
    
    /// Print a menu
    /// - Parameters:
    ///   - options: Menu options
    ///   - title: Menu title (optional)
    func printMenu(_ options: [String], title: String = "Menu Options") {
        printSubheader(title)
        
        for (index, option) in options.enumerated() {
            print("\(index + 1). \(option)".lightYellow)
        }
        
        print("\nEnter your choice (1-\(options.count)): ".yellow, terminator: "")
    }
    
    /// Print an info message
    /// - Parameter message: Message to print
    func printInfo(_ message: String) {
        print("ℹ️  \(message)".blue)
    }
    
    /// Print a success message
    /// - Parameter message: Message to print
    func printSuccess(_ message: String) {
        print("✅ \(message)".green)
    }
    
    /// Print a warning message
    /// - Parameter message: Message to print
    func printWarning(_ message: String) {
        print("⚠️  \(message)".yellow)
    }
    
    /// Print an error message
    /// - Parameter message: Message to print
    func printError(_ message: String) {
        print("❌ \(message)".red)
    }
    
    /// Print a table
    /// - Parameters:
    ///   - headers: Table headers
    ///   - rows: Table rows
    ///   - title: Table title
    func printTable(headers: [String], rows: [[String]], title: String? = nil) {
        if let title = title {
            printSubheader(title)
        }
        
        // Calculate column widths
        var columnWidths: [Int] = []
        
        for (index, header) in headers.enumerated() {
            var maxWidth = header.count
            
            for row in rows {
                if index < row.count {
                    maxWidth = max(maxWidth, row[index].count)
                }
            }
            
            columnWidths.append(maxWidth + 2) // Add padding
        }
        
        // Print headers
        var headerRow = "| "
        for (index, header) in headers.enumerated() {
            let paddedHeader = header.padding(toLength: columnWidths[index], withPad: " ", startingAt: 0)
            headerRow += paddedHeader + " | "
        }
        print(headerRow.cyan)
        
        // Print separator
        var separator = "+"
        for width in columnWidths {
            separator += String(repeating: "-", count: width + 2) + "+"
        }
        print(separator.cyan)
        
        // Print rows
        for row in rows {
            var rowString = "| "
            for (index, column) in row.enumerated() {
                if index < columnWidths.count {
                    let paddedColumn = column.padding(toLength: columnWidths[index], withPad: " ", startingAt: 0)
                    rowString += paddedColumn + " | "
                }
            }
            print(rowString)
        }
        
        // Print bottom border
        print(separator.cyan)
    }
    
    /// Print a progress bar
    /// - Parameters:
    ///   - progress: Progress value (0.0 to 1.0)
    ///   - width: Width of the progress bar
    ///   - title: Title for the progress bar
    func printProgressBar(progress: Double, width: Int = 40, title: String? = nil) {
        let clampedProgress = min(1.0, max(0.0, progress))
        let completedWidth = Int(Double(width) * clampedProgress)
        let remainingWidth = width - completedWidth
        
        if let title = title {
            print("\(title): ".lightYellow, terminator: "")
        }
        
        let progressBar = String(repeating: "█", count: completedWidth) + String(repeating: "░", count: remainingWidth)
        let percentage = Int(clampedProgress * 100)
        
        print("[\(progressBar)] \(percentage)%")
    }
    
    /// Print a file list
    /// - Parameter files: Files to display
    func printFileList(_ files: [SyncFile]) {
        if files.isEmpty {
            printInfo("No files found.")
            return
        }
        
        var rows: [[String]] = []
        
        for file in files {
            let statusSymbol: String
            let statusColor: (String) -> String
            
            switch file.syncStatus {
            case .synced:
                statusSymbol = "✓"
                statusColor = { $0.green }
            case .pending:
                statusSymbol = "⏱"
                statusColor = { $0.yellow }
            case .syncing:
                statusSymbol = "↻"
                statusColor = { $0.blue }
            case .conflict:
                statusSymbol = "⚠️"
                statusColor = { $0.red }
            case .error:
                statusSymbol = "✗"
                statusColor = { $0.red }
            }
            
            let row = [
                statusColor(statusSymbol),
                file.name,
                file.formattedSize,
                file.mimeType,
                file.modifiedAt.formatted(date: .abbreviated, time: .shortened)
            ]
            
            rows.append(row)
        }
        
        printTable(
            headers: ["Status", "Name", "Size", "Type", "Modified"],
            rows: rows,
            title: "Files"
        )
    }
    
    /// Read a line from standard input
    /// - Parameter prompt: Prompt to display
    /// - Returns: Input string
    func readLine(prompt: String? = nil) -> String? {
        if let prompt = prompt {
            print(prompt, terminator: "")
        }
        return Swift.readLine()
    }
    
    /// Read an integer from standard input
    /// - Parameter prompt: Prompt to display
    /// - Returns: Input integer
    func readInt(prompt: String? = nil) -> Int? {
        guard let input = readLine(prompt: prompt) else {
            return nil
        }
        
        return Int(input)
    }
    
    /// Read a yes/no response from standard input
    /// - Parameter prompt: Prompt to display
    /// - Returns: Boolean indicating yes (true) or no (false)
    func readYesNo(prompt: String) -> Bool {
        while true {
            guard let input = readLine(prompt: "\(prompt) (y/n): ") else {
                return false
            }
            
            switch input.lowercased() {
            case "y", "yes":
                return true
            case "n", "no":
                return false
            default:
                printError("Please enter 'y' or 'n'.")
            }
        }
    }
    
    /// Clear the screen
    func clearScreen() {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
    }
}
