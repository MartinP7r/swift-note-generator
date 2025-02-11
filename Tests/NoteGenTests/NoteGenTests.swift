import ArgumentParser
import ArgumentParserTestHelpers
import Files
import XCTest
import class Foundation.Bundle

// TODO: rename to `JournalTests`
final class NoteGenTests: XCTestCase {

    private var productsFolder: Folder!
    private var templateFolder: Folder!
    private var daybookFolder: Folder!

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

    func test_output_tomorrow() throws {
        let expectedString = prepareExpectedForTestTomorrow()
        try AssertExecuteCommand(command: "note-gen --tomorrow", expected: expectedString)
    }

    func test_output_tmr() throws {
        let expectedString = prepareExpectedForTestTomorrow()
        try AssertExecuteCommand(command: "note-gen --tmr", expected: expectedString)
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

        XCTAssertEqual("some content", try getFileContents())
    }

    func test_overwriteOption() throws {
        try productsFolder.createFile(at: pathString, contents: "some content".data(using: .utf8))
        XCTAssertTrue(productsFolder.containsFile(at: pathString))

        try AssertExecuteCommand(
            command: "note-gen -d \(dateString) --overwrite",
            expected: pathString
        )

        XCTAssertNotEqual("some content", try getFileContents())
    }

    func test_singleDigitMonth() throws {
        let dateString = "2022-05-02"
        let pathString = "daybook/2022/05/2022-05-02.md"
        try AssertExecuteCommand(
            command: "note-gen -d \(dateString)",
            expected: pathString
        )
    }

    func test_tagsAreReplaced() throws {
        let tags = ["one", "two", "three", "swift"]
        let parameterString = tags.joined(separator: " ")
        let resultString = tags.joined(separator: ", ")

        let template = """
            ---
            date: %date%
            category: daybook
            tags: [%tags%]
            ---
            """
        let templateAfter = """
            ---
            date: \(dateString)
            category: daybook
            tags: [\(resultString)]
            ---
            """

        try templateFolder.empty()
        try templateFolder.createFile(at: "daily.md",
                                      contents: template.data(using: .utf8))

        try AssertExecuteCommand(command: "note-gen -d \(dateString) --tags \(parameterString)")
        XCTAssertEqual(templateAfter, try getFileContents())
    }
}

private extension NoteGenTests {
    func prepareExpectedForTestTomorrow() -> String {
        let cal = Calendar.current
        let tmr = cal.date(byAdding: .day, value: 1, to: Date())!
        let expectedDateString = String(tmr.formatted(.iso8601).prefix(10))
        let comps = cal.dateComponents([.day, .month, .year], from: tmr)
        let month = comps.month.map { $0 < 10 ? "0\($0)" : "\($0)" }!
        let year = "\(comps.year!)"
        return "daybook/\(year)/\(month)/\(expectedDateString).md"
    }

    private func getFileContents() throws -> String {
        try productsFolder.file(at: pathString).readAsString()
    }
}
