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

extension Array {
    mutating func moveElement(from source: Index, to destination: Index) {
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        self.insert(self[source], at: destination)
        if source < destination {
            self.remove(at: source)
        } else {
            self.remove(at: source.advanced(by: 1))
        }
        semaphore.signal()
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

extension CMTime {
    /// String formatted as 01:10:20,450
    var formatted: String {
        let t = self.seconds, h = Int(t / 3600), m = Int(t.truncatingRemainder(dividingBy: 3600) / 60), s = Int(t.truncatingRemainder(dividingBy: 60)), u = (t.truncatingRemainder(dividingBy: 1) * 1000)
        return String(format: "%02i:%02i:%02i,%03.0f", h, m, s, u)
    }
}
