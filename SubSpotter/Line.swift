//
//  Line.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-17.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import AVFoundation

/// One timeset subtitle with start and end times
struct Line: Equatable, Hashable {
    let start: CMTime
    let end:   CMTime
    let text:  String
}


extension Line: CustomStringConvertible {
    var description: String {
        return String(format: "%@ — %@ : %@", start.description, end.description, text)
    }
}
