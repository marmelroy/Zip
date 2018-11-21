import XCTest

extension ZipTests {
    static let __allTests = [
        ("testAddedCustomFileExtensionIsValid", testAddedCustomFileExtensionIsValid),
        ("testDefaultFileExtensionsIsNotRemoved", testDefaultFileExtensionsIsNotRemoved),
        ("testDefaultFileExtensionsIsValid", testDefaultFileExtensionsIsValid),
        ("testFileExtensionIsInvalidForInvalidUrl", testFileExtensionIsInvalidForInvalidUrl),
        ("testFileExtensionIsNotInvalidForValidUrl", testFileExtensionIsNotInvalidForValidUrl),
        ("testImplicitProgressUnzip", testImplicitProgressUnzip),
        ("testImplicitProgressZip", testImplicitProgressZip),
        ("testQuickUnzip", testQuickUnzip),
        ("testQuickUnzipNonExistingPath", testQuickUnzipNonExistingPath),
        ("testQuickUnzipNonZipPath", testQuickUnzipNonZipPath),
        ("testQuickUnzipOnlineURL", testQuickUnzipOnlineURL),
        ("testQuickUnzipProgress", testQuickUnzipProgress),
        ("testQuickUnzipSubDir", testQuickUnzipSubDir),
        ("testQuickZip", testQuickZip),
        ("testQuickZipFolder", testQuickZipFolder),
        ("testRemovedCustomFileExtensionIsInvalid", testRemovedCustomFileExtensionIsInvalid),
        ("testUnzip", testUnzip),
        ("testUnzipPermissions", testUnzipPermissions),
        ("testUnzipWithUnsupportedPermissions", testUnzipWithUnsupportedPermissions),
        ("testZip", testZip),
        ("testZipUnzipPassword", testZipUnzipPassword),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ZipTests.__allTests),
    ]
}
#endif
