//
//  Line.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-17.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import AVFoundation

struct Line: Equatable, Hashable {
    let start: CMTime
    let end:   CMTime
    let text:  String
}

class LineWrapper: NSObject {
    let line: Line
    
    init(_ line: Line) {
        self.line = line
    }

    required init?(coder aDecoder: NSCoder) {
        let s = aDecoder.decodeTime(forKey: "start")
        let e = aDecoder.decodeTime(forKey: "end")
        let t = aDecoder.decodeObject(forKey: "text") as? String ?? ""
        self.line = Line(start: s, end: e, text: t)
    }
}

extension Line: CustomStringConvertible {
    var description: String {
        return String(format: "%@ — %@ : %@", start.description, end.description, text)
    }
}

extension LineWrapper: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(line.start, forKey: "start")
        aCoder.encode(line.end,   forKey: "end")
        aCoder.encode(line.text,  forKey: "text")
    }
}

import Cocoa

extension LineWrapper: NSPasteboardWriting {
    
    static let pasteboardType: NSPasteboard.PasteboardType = .init("")
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [LineWrapper.pasteboardType]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        if type == .string {
            // TODO: Implement and forward to CustomStringConvertible
        }
        guard type == LineWrapper.pasteboardType else { print("Incorrect paste type:", type); return nil }
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        let values: [String: Any] = ["root": data]
        do {
            let plist = try PropertyListSerialization.data(fromPropertyList: values, format: .binary, options: 0)
            return plist
        } catch {
            print("Plist serialisation error:", error)
            return nil
        }
    }
}
