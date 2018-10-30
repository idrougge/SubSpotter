//
//  Importer.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-19.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Foundation

protocol Importer {
    associatedtype ImportedLine
    func getLines(from: URL) throws -> [ImportedLine]
}

struct TextImporter: Importer {
    typealias ImportedLine = String
    func getLines(from url: URL) throws -> [String] {
        let text = try NSAttributedString(url: url, options: [:], documentAttributes: nil).string
        let lines = text
            .components(separatedBy: .newlines)
            .filter{ !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines
    }
}

struct SrtImporter: Importer {
    typealias ImportedLine = Line
    
    enum ImportError: Error {
        case malformed(_ line: String)
    }
    
    func getLines(from url: URL) throws -> [Line] {
        let text = try String(contentsOf: url, encoding: .utf8)
        // SRT files have a blank line for separating insertions
        let rawLines = text.components(separatedBy: "\n\n")
        print(rawLines)
        return try getLines(from: rawLines)
    }
    
    func getLines(from lines: [String]) throws -> [Line] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss,SSS"
        let referenceDate = formatter.date(from: "00:00:00,000")!
        
        return try lines.compactMap{ insertion -> Line? in
            let lines = insertion.components(separatedBy: .newlines)
            guard lines.count > 2 else { return nil } // Each insertion must contain ordinal, time and at least one text row
            let timeRow = lines[1]
            let times = timeRow
                .components(separatedBy: " --> ")
                .compactMap{ time in
                    formatter
                        .date(from: time)?
                        .timeIntervalSince(referenceDate)
            }
            guard times.count == 2 else { throw ImportError.malformed(insertion)}
            let text = lines[2...].joined(separator: "\n")
            let line = Line(start: times[0], end: times[1], text: text)
            return line
        }
    }
}
