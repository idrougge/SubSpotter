//
//  Importer.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-19.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Foundation

protocol Importer {
    func getLines(from: URL) throws -> [String]
}

struct TextImporter: Importer {
    func getLines(from url: URL) throws -> [String] {
        let text = try NSAttributedString(url: url, options: [:], documentAttributes: nil).string
        let lines = text
            .components(separatedBy: .newlines)
            .filter{ !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines
    }
}
