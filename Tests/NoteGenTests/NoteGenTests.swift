import ArgumentParser
import Files
import XCTest
import class Foundation.Bundle

final class NoteGenTests: XCTestCase {

    private var templateFolder: Folder!
    private var daybookFolder: Folder!
    private var productsFolder: Folder!

    private var dateString = "2021-12-31"
    private var pathString = "daybook/2021/12/2021-12-31.md"

    override func setUpWithError() throws {
        try super.setUpWithError()

        productsFolder = try Folder(path: productsDirectory.path)
        templateFolder = try productsFolder.createSubfolderIfNeeded(withName: "templates")
        try templateFolder.empty()
        try templateFolder.createFile(at: "daily.md",
                                      contents: "Today's date is %date%.".data(using: .utf8))
        daybookFolder = try productsFolder.createSubfolderIfNeeded(withName: "daybook")
        try daybookFolder.empty()

        XCTAssertFalse(productsFolder.containsFile(at: pathString))
    }

    override func tearDownWithError() throws {
        try? templateFolder.delete()
        try? daybookFolder.delete()
        try super.tearDownWithError()
    }

    func test_output() throws {
        try AssertExecuteCommand(
            command: "note-gen --date \(dateString)",
            expected: pathString
        )
    }

    func test_output_short() throws {
        try AssertExecuteCommand(
            command: "note-gen -d \(dateString)",
            expected: pathString
        )
    }

    func test_output_parameter_verbose() throws {
        try AssertExecuteCommand(
            command: "note-gen journal -d \(dateString)",
            expected: pathString
        )
    }

    func test_fileIsCreated() throws {
        XCTAssertFalse(productsFolder.containsFile(at: pathString))
        try AssertExecuteCommand(
            command: "note-gen -d \(dateString)",
            expected: pathString
        )
        XCTAssertTrue(productsFolder.containsFile(at: pathString))
    }

    func test_dateReplacesPlaceholder() throws {
        XCTAssertFalse(productsFolder.containsFile(at: pathString))
        try AssertExecuteCommand(
            command: "note-gen -d \(dateString)",
            expected: pathString
        )

        let file = try productsFolder.file(at: pathString)
        let contents = try file.readAsString()
        XCTAssertEqual(contents, "Today's date is \(dateString).")
    }

    func test_fileIsNotOverwritten() throws {
        try productsFolder.createFile(at: pathString, contents: "some content".data(using: .utf8))
        XCTAssertTrue(productsFolder.containsFile(at: pathString))

        try AssertExecuteCommand(
            command: "note-gen -d \(dateString)",
            expected: "File already exists: \(pathString)"
        )

        XCTAssertEqual("some content", try productsFolder.file(at: pathString).readAsString())
    }

    func test_overwriteOption() throws {}
}
