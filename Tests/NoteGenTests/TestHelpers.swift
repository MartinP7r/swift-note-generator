////
////  File.swift
////
////
////  Created by Martin Pfundmair on 2022-03-05.
////
//
//import ArgumentParser
import XCTest
//
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
}
