import XCTest

import ZipTests

var tests = [XCTestCaseEntry]()
tests += ZipTests.__allTests()

XCTMain(tests)
