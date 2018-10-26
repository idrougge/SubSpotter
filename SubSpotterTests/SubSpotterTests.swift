//
//  SubSpotterTests.swift
//  SubSpotterTests
//
//  Created by Iggy Drougge on 2018-10-26.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import XCTest
import AVFoundation

class SubSpotterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTimeFormatter() {
        // Just a generic time
        var time = CMTime(value: 1178358419, timescale: 1000000000)
        XCTAssert(time.formatted == "00:00:01,178")
        // This time should be rounded up from 4,17878 to 4,179
        time = CMTime(value: 4178780039, timescale: 1000000000)
        XCTAssert(time.formatted == "00:00:04,179", "This time should be rounded up from 4,17878 to 4,179")
        time = CMTime(value: 4795687999, timescale: 1000000000)
        XCTAssert(time.formatted == "00:00:05,796")
        time = CMTime(value: 60014613663, timescale: 1000000000)
        XCTAssert(time.formatted == "00:01:00,015", "Past one minute: \(CMTimeCopyDescription(allocator: nil, time: time)!)")
        time = CMTime(value: 36057, timescale: 600)
        XCTAssert(time.formatted == "00:01:00,095", "Verifying different timescale, past one minute: \(CMTimeCopyDescription(allocator: nil, time: time)!)")
    }

}
