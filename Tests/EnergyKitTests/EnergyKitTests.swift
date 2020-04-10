import XCTest
@testable import EnergyKit

final class EnergyKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(EnergyKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
