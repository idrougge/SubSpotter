//
//  Exporter.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-18.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Foundation

protocol Exporter {
    init(list: [Line])
    func export(to: URL) throws
}

class SrtExporter: Exporter {
    private let sourceList: [Line]
    
    required init(list: [Line]) {
        self.sourceList = list
    }
    
    func export(to destination: URL) throws {
        //try FileManager.default.removeItem(at: destination)
        let stream = OutputStream(url: destination, append: false)
        stream?.open()
        for (row, line) in sourceList.enumerated() {
            // Time format should be 00:01:20,000 --> 00:01:24,400
            let output = """
            \(row)
            \(line.start.formatted) --> \(line.end.formatted)
            \(line.text)\n\n
            """
            stream?.write([UInt8](output.utf8), maxLength: output.utf8.count)
        }
        stream?.close()
    }
}
