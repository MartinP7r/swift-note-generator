import ArgumentParser
import Files
import Foundation

@main
struct DaybookGen: ParsableCommand {
    
    static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    @Argument(help: "The template file to use.")
    var template: String = "sample_data/templates/daily.md"
    
    @Option(name: .shortAndLong, help: "The date to use for a new file. (default: today)")
    var date: String?
    
    @Argument(help: "The daybook directory to use.")
    private var daybookDir = "sample_data/daybook"

    mutating func run() throws {
        let date = date ?? String(Self.dateFormatter.string(from: Date()))
        let monthlyFolderName = String(date.prefix(7))
        let array = monthlyFolderName.components(separatedBy: "-")
        let yearString = array[0]
        let monthString = array[1]

        let daybookFolder = try Folder(path: daybookDir)

        // Create monthly folder if not present
        if !daybookFolder.subfolders.contains(where: { $0.name == yearString }) {
            try daybookFolder.createSubfolder(at: yearString)
        }
        let yearlyFolder = try daybookFolder.subfolder(at: yearString)

        if !yearlyFolder.subfolders.contains(where: { $0.name == monthString }) {
            try yearlyFolder.createSubfolder(at: monthString)
        }
        let monthlyFolder = try yearlyFolder.subfolder(at: monthString)

        let template = try File(path: template)
        let templateText = try template.readAsString()
        let newText = templateText.replacingOccurrences(of: "%date%", with: date)


        try monthlyFolder.createFile(at: "\(date).md",
                                     contents: newText.data(using: .utf8))

    }

}
