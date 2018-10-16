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
