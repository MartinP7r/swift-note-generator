import ArgumentParser
import Files

// for file in try Folder(path: ".").files {
//     print(file.name)
// }

@main
struct Gen: ParsableCommand {

    mutating func run() throws {
        print("Hello")
    }
}
