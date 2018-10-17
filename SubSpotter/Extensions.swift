//
//  Extensions.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-16.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Foundation

extension TimeInterval {
    /// Given a frames per second value, return a time interval for one frame
    init(frames: Float) {
        self.init(1/frames)
    }
}

import AVFoundation

extension CMTime {
    static func + (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return CMTime(seconds: lhs.seconds + rhs,
                      preferredTimescale: lhs.timescale)
    }
    
    static func += (lhs: inout CMTime, rhs: TimeInterval) {
        lhs = CMTime(seconds: lhs.seconds + rhs,
                      preferredTimescale: lhs.timescale)
    }
    
}

extension CMTime: Hashable {
    public var hashValue: Int { return self.value.hashValue }
}

extension CMTime: CustomStringConvertible {
    public var description: String {
        return String(format: "%06.3f", seconds)
    }
}
