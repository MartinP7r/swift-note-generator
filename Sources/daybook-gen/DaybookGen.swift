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
    
    @Argument(help: "The template file to use.")
    var template: String = "sample_data/templates/daily.md"
    
    @Argument(help: "The date to use for a new file.")
    var date: String?
    
    @Argument(help: "The daybook directory to use.")
    private var daybookDir = "sample_data/daybook"

    mutating func run() throws {
        let date = date ?? String(Self.dateFormatter.string(from: Date()))
        let monthlyFolderName = String(date.prefix(7))
        let daybookFolder = try Folder(path: daybookDir)

        // Create monthly folder if not present
        if !daybookFolder.subfolders.contains(where: { $0.name == monthlyFolderName }) {
            try daybookFolder.createSubfolder(at: monthlyFolderName)
        }

        let template = try File(path: template)
        let templateText = try template.readAsString()
        let newText = templateText.replacingOccurrences(of: "%date%", with: date)

        let monthlyFolder = try daybookFolder.subfolder(at: monthlyFolderName)

        try monthlyFolder.createFile(at: "\(date).md",
                                     contents: newText.data(using: .utf8))

    }

}
