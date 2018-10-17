//
//  LineWrapper.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-17.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Cocoa

/// Wrapper for Line to support Cocoa methods such as NSCoder and NSPasteboard
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
    
    public required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        guard
            type == LineWrapper.pasteboardType,
            let not_a_propertyList = propertyList as? LineWrapper else {
                print("Not instance of self!")
                return nil
        }
        self.line = not_a_propertyList.line
    }
}

// MARK: NSCoding
extension LineWrapper: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(line.start, forKey: "start")
        aCoder.encode(line.end,   forKey: "end")
        aCoder.encode(line.text,  forKey: "text")
    }
}

// MARK: NSPasteboardWriting
extension LineWrapper: NSPasteboardWriting {
    
    static let pasteboardType: NSPasteboard.PasteboardType = .init("line")
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [LineWrapper.pasteboardType, .string]
    }
    
    func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
        return NSPasteboard.WritingOptions.promised
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .string:
            return NSString.pasteboardPropertyList(line.description as NSString)
        case LineWrapper.pasteboardType:
            return NSKeyedArchiver.archivedData(withRootObject: self)
        default:
            print("Incorrect paste type:", type)
            return nil
        }
    }
}

// MARK: NSPasteboardReading
extension LineWrapper: NSPasteboardReading {
    static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [LineWrapper.pasteboardType]
    }
    
    static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        return [NSPasteboard.ReadingOptions.asKeyedArchive]
    }
}
