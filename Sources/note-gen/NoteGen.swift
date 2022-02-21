import ArgumentParser
import Files
import Foundation


extension NoteGen {

    struct Journal: ParsableCommand {
        @Option(name: [.long, .short],
            help: "The date to use for a new file. Format: yyyy-MM-dd (default: today)",
                  transform: parseDate(NoteGen.dateFormatter))
        var date: Date

        @Argument(help: "The template file to use.")
        var template: String = ".templates/daily.md"

        //    // TODO: enum .today .tommorrow .date(String)
        //    @Option(name: [.customLong("date"), .short],
        //            help: "The date to use for a new file. Format: yyyy-MM-dd (default: today)")
        //    var dateString: String?
        //
        //    private var date: Date!
        private var year: Int { Calendar.current.component(.year, from: date) }
        private var month: Int { Calendar.current.component(.month, from: date) }

        //    private var yearString: String!  // = "2022"
        //    private var monthString: String! // = "01"

        @Argument(help: "The directory to use.")
        var daybookDir = "daybook"

        @Flag(help: "Move unfinished TODOs from earlier days")
        var moveTodos = false

        //    @Flag(help: "Move questions from previous day")

        mutating func run() throws {
            //        try initializeProps()
            let dateString = NoteGen.dateFormatter.string(from: date)  // else { throw Error.invalidDate }

            let monthlyFolder = try getMonthlyFolder()

            let template = try File(path: template)
            let templateText = try template.readAsString()
            var newText = templateText.replacingOccurrences(of: "%date%", with: dateString)

            if moveTodos {
                getPreviousDaysQuestions()
            } else {
                newText = newText.replacingOccurrences(of: "%todos%", with: "")
            }

            try monthlyFolder.createFile(at: "\(dateString).md",
                                         contents: newText.data(using: .utf8))

        }

        private func getMonthlyFolder() throws -> Folder {
            let yearString = String(year)
            let monthString = String(month).padding(toLength: 2, withPad: "0", startingAt: 0)

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
        }    }
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

@main
struct NoteGen: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for creating markdown files based on templates.",
        //        version: "1.0.0",
        subcommands: [Journal.self, Snippet.self],
        defaultSubcommand: Journal.self)

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    enum Error: Swift.Error {
        case invalidDate
    }

}
