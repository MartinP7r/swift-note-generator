import ArgumentParser
import Files
import Foundation

@main
struct NoteGen: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for creating markdown files based on templates.",
        version: "0.0.8",
        subcommands: [Journal.self, Snippet.self],
        defaultSubcommand: Journal.self
    )

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    enum Error: Swift.Error {
        case invalidDate
    }
}

extension NoteGen {
    struct Journal: ParsableCommand {

        @Argument(help: "The template file to use.")
        var template: String = "templates/daily.md" // ".note-gen/templates/daily.md"

        @Option(name: [.long, .short],
                help: "The date to use for a new file. Format: yyyy-MM-dd (default: today)",
                transform: parseDate(NoteGen.dateFormatter))
        var date: Date = Date()
        private var year: Int { Calendar.current.component(.year, from: date) }
        private var month: Int { Calendar.current.component(.month, from: date) }

        @Flag(name: [.long, .customLong("tmr")]) var tomorrow = false

        @Flag(help: "Overwrite the file if it already exists")
        var overwrite: Bool = false

        @Argument(help: "The directory to use.")
        var daybookDir = "daybook"

        @Option
        private var category: String = "daybook"

        @Option(name: [.long, .short], parsing: .upToNextOption)
        private var tags: [String] = []

        @Option
        private var moveTemplateKeywords: [String] = []
//        @Flag(help: "Move unfinished TODOs from earlier days")
//        var moveTodos = false

        mutating func run() throws {
            if tomorrow,
               let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                date = newDate
            }
            let dateString = NoteGen.dateFormatter.string(from: date)

            let monthlyFolder = try getMonthlyFolder()

            let template = try File(path: template)
            let templateText = try template.readAsString()
            var newText = templateText.replacingOccurrences(of: "%date%", with: dateString)

            // TODO: move keywords instead of `moveTodos` below
//            if moveTodos {
//                getPreviousDaysQuestions()
//            } else {
//                newText = newText.replacingOccurrences(of: "%todos%", with: "")
//            }

            if !tags.isEmpty {
                newText = newText.replacingOccurrences(of: "%tags%", with: tags.joined(separator: ", "))
            }

            let pathString = "\(monthlyFolder.path)\(dateString).md"
            if !overwrite && monthlyFolder.containsFile(at: "\(dateString).md") {
                print("File already exists: \(pathString)")
            } else {
                try monthlyFolder.createFile(at: "\(dateString).md",
                                             contents: newText.data(using: .utf8))
                print("\(monthlyFolder.path)\(dateString).md")
            }
        }

        private func getMonthlyFolder() throws -> Folder {
            let yearString = String(year)
            let monthString = String(
                String(String(month).reversed())
                    .padding(toLength: 2, withPad: "0", startingAt: 0)
                    .reversed()
            )

            let daybookFolder = try Folder(path: daybookDir)
            // Create monthly folder if not present
            if !daybookFolder.subfolders.contains(where: { $0.name == yearString }) {
                try daybookFolder.createSubfolder(at: yearString)
            }
            let yearlyFolder = try daybookFolder.subfolder(at: yearString)

            if !yearlyFolder.subfolders.contains(where: { $0.name == monthString }) {
                try yearlyFolder.createSubfolder(at: monthString)
            }

            return try yearlyFolder.subfolder(at: monthString)
        }

        private func getFolder(for date: Date, createIfNeeded: Bool = true) throws -> Folder {
            // implement
            fatalError()
        }

        private func getPreviousDaysQuestions() {
            //        print("\(monthlyFolder.path)\(date).md")
        }
    }
}

extension NoteGen {
    struct Snippet: ParsableCommand {

        @OptionGroup var options: Options

        @Argument(help: "The template file to use.")
        var template: String = ".templates/snippet.md"

        mutating func run() {
            print("\(options.date.debugDescription) \(template)")
        }
    }
}

private func parseDate(_ formatter: DateFormatter) -> (String) throws -> Date {
    { arg in
        guard let date = formatter.date(from: arg) else {
            throw ValidationError("Invalid date")
        }
        return date
    }
}

struct Options: ParsableArguments {
    @Argument(help: "The date to use for a new file. Format: yyyy-MM-dd (default: today)",
              transform: parseDate(NoteGen.dateFormatter))
    var date: Date = Date()
}
