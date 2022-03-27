//
//  File.swift
//  
//
//  Created by Martin Pfundmair on 2022-03-05.
//

import ArgumentParser
import XCTest

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

    public func AssertExecuteCommand(
        command: String,
        expected: String? = nil,
        exitCode: ExitCode = .success,
        file: StaticString = #file, line: UInt = #line
    ) throws {
        let splitCommand = command.split(separator: " ")
        let arguments = splitCommand.dropFirst().map(String.init)

        let commandName = String(splitCommand.first!)
        let commandURL = debugURL.appendingPathComponent(commandName)
        guard (try? commandURL.checkResourceIsReachable()) ?? false else {
            XCTFail("No executable at '\(commandURL.standardizedFileURL.path)'.",
                    file: (file), line: line)
            return
        }

#if !canImport(Darwin) || os(macOS)
        let process = Process()
        if #available(macOS 10.13, *) {
            process.executableURL = commandURL
        } else {
            process.launchPath = commandURL.path
        }
        process.arguments = arguments

        let output = Pipe()
        process.standardOutput = output
        let error = Pipe()
        process.standardError = error

        if #available(macOS 10.13, *) {
            guard (try? process.run()) != nil else {
                XCTFail("Couldn't run command process.", file: (file), line: line)
                return
            }
        } else {
            process.launch()
        }
        process.waitUntilExit()

        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        let outputActual = String(data: outputData, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)

        let errorData = error.fileHandleForReading.readDataToEndOfFile()
        let errorActual = String(data: errorData, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)

        if let expected = expected {
            AssertEqualStringsIgnoringTrailingWhitespace(expected, errorActual + outputActual, file: file, line: line)
        }

        XCTAssertEqual(process.terminationStatus, exitCode.rawValue, file: (file), line: line)
#else
        throw XCTSkip("Not supported on this platform")
#endif
    }

    private func AssertEqualStringsIgnoringTrailingWhitespace(_ string1: String, _ string2: String, file: StaticString = #file, line: UInt = #line) {
        let lines1 = string1.split(separator: "\n", omittingEmptySubsequences: false)
        let lines2 = string2.split(separator: "\n", omittingEmptySubsequences: false)

        XCTAssertEqual(lines1.count, lines2.count, "Strings have different numbers of lines.", file: (file), line: line)
        for (line1, line2) in zip(lines1, lines2) {
            XCTAssertEqual(line1.trimmed(), line2.trimmed(), file: (file), line: line)
        }
    }
}

extension XCTest {
    public var debugURL: URL {
        let bundleURL = Bundle(for: type(of: self)).bundleURL
        return bundleURL.lastPathComponent.hasSuffix("xctest")
        ? bundleURL.deletingLastPathComponent()
        : bundleURL
    }
}


extension Substring {
    func trimmed() -> Substring {
        guard let i = lastIndex(where: { $0 != " "}) else {
            return ""
        }
        return self[...i]
    }
}

extension String {
    public func trimmingLines() -> String {
        return self
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmed() }
            .joined(separator: "\n")
    }
}
