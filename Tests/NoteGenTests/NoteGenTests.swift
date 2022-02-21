import Files
import XCTest
import class Foundation.Bundle

final class NoteGenTests: XCTestCase {

    private var templateFolder: Folder!
    private var daybookFolder: Folder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        templateFolder = try Folder(path: productsDirectory.path)
            .createSubfolderIfNeeded(withName: ".templates")
        try templateFolder.empty()
        daybookFolder = try Folder(path: productsDirectory.path)
            .createSubfolderIfNeeded(withName: ".templates")
        try daybookFolder.empty()
    }

    override func tearDownWithError() throws {
        try templateFolder.delete()
        try daybookFolder.delete()
        try super.tearDownWithError()
    }

    func test_daybookIsCreated() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)

        print(productsDirectory)
        let fooBinary = productsDirectory.appendingPathComponent("note-gen")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["--date 2021-12-31"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, "Hello, world!\n")
        #endif
    }

    /// Returns path to the built products directory.
//    var productsDirectory: URL {
//      #if os(macOS)
//        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
//            return bundle.bundleURL.deletingLastPathComponent()
//        }
//        fatalError("couldn't find the products directory")
//      #else
//        return Bundle.main.bundleURL
//      #endif
//    }
}

extension XCTest {
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    func prepareTemplateFolder() {

    }
}
