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
        func seconds(h: Int, m: Int, s: Int, ms: Int) -> TimeInterval {
            return Double(h * 3600) + Double(m * 60) + Double(s) + (Double(ms) / 1000)
        }
        let regex = try NSRegularExpression(pattern: "(\\d{2}):(\\d{2}):(\\d{2}),(\\d{3}) --> (\\d{2}):(\\d{2}):(\\d{2}),(\\d{3})", options: [])
        return try lines.compactMap{ insertion -> Line? in
            let lines = insertion.components(separatedBy: .newlines)
            guard let ordinal = lines.first, lines.count > 2 else { return nil }
            /*
             let scanner = Scanner(string: ordinal)
             scanner.charactersToBeSkipped = CharacterSet(charactersIn: ":,")
             var h: Int = -1
             scanner.scanInt(&h)
             print("h =", h)
             */
            let timeRow = lines[1]
            guard
                let match = regex.firstMatch(in: timeRow,
                                             options: [],
                                             range: NSRange(timeRow.startIndex..., in: timeRow)),
                match.numberOfRanges == 9
                else { throw ImportError.malformed(insertion) }
            let ranges: [Range<String.Index>] = try (1 ..< match.numberOfRanges).compactMap{ nr in
                let nsrange = match.range(at: nr)
                guard let range = Range(nsrange, in: timeRow) else { throw ImportError.malformed(insertion) }
                return range
            }
            let matches: [Int] = try ranges.map{ range in
                let substring = String(timeRow[range])
                guard let time = Int(substring) else { throw ImportError.malformed(insertion) }
                return time
            }
            let start = seconds(h: matches[0], m: matches[1], s: matches[2], ms: matches[3])
            let end = seconds(h: matches[4], m: matches[5], s: matches[6], ms: matches[7])
            let text = lines[2...].joined(separator: "\n")
            let line = Line(start: start, end: end, text: text)
            return line
        }
    }
}
