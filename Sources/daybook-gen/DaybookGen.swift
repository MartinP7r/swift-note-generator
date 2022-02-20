import ArgumentParser
import Files
import Foundation

@main
struct DaybookGen: ParsableCommand {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    enum Error: Swift.Error {
        case invalidDate
    }

    // TODO: .today .tommorrow flags
    
    @Argument(help: "The template file to use.")
    var template: String = ".templates/daily.md"
    
    @Option(name: [.customLong("date"), .short], help: "The date to use for a new file. Format: yyyy-MM-dd (default: today)")
    var dateString: String?

    private var date: Date!
    private var yearString: String!  // = "2022"
    private var monthString: String! // = "01"

    @Argument(help: "The directory to use.")
    var daybookDir = "daybook"

    @Flag(help: "Move unfinished TODOs from earlier days")
    var moveTodos = false

    //    @Flag(help: "Move questions from previous day")

    mutating func run() throws {
        try initializeProps()
        guard let dateString = dateString else { throw Error.invalidDate }

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

    mutating private func initializeProps() throws {
        if dateString == nil {
            dateString = String(Self.dateFormatter.string(from: Date()))
        }
        guard let dateString = dateString else { throw Error.invalidDate }
        date = DaybookGen.dateFormatter.date(from: dateString)
        let monthlyFolderName = String(dateString.prefix(7))
        let arr = monthlyFolderName.components(separatedBy: "-")
        yearString = arr[0]
        monthString = arr[1]
    }

    private func getMonthlyFolder() throws -> Folder {
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
