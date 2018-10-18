//
//  Subtitles.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-17.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Foundation
import AVFoundation

class Subtitles: NSObject {
    
    private var staged: Line?
    private var lines: [Line] = []
    
    /// Current playback time is updated regularly by the player
    public var currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: 0)
    
    func stage(text: String, at time: CMTime) {
        let secondsToShow: TimeInterval = 3 // Should be calculated according to text length + K
        let endTime = time + secondsToShow
        staged = Line(start: time, end: endTime, text: nextLine)
    }
    
    func commit() -> Array<Line>.Index {
        guard let endTime = staged?.end, endTime <= currentTime
            else {
                return lines.index(before: lines.endIndex)
        }
        return commit(at: endTime)
    }
    
    func commit(completion: (Array<Line>.Index)->()) {
        guard let endTime = staged?.end, endTime <= currentTime else { return }
        completion(commit(at: endTime))
    }
    
    func commit(at endTime: CMTime) -> Array<Line>.Index {
        guard let staged = staged else { return lines.index(before: lines.endIndex)}
        let index = lines.endIndex
        let line = Line(start: staged.start, end: endTime, text: staged.text)
        lines.append(line)
        self.staged = nil
        return index
    }
    
    var nextLine: String {
        return "Textrad nr \(lines.endIndex)"
    }
}

// MARK: - NSTableViewDataSource
import Cocoa

extension Subtitles: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return lines.count
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        //print(#function, row)
        let time: CMTime
        
        switch tableColumn?.identifier.rawValue {
        case "start": time = lines[row].start
        case "end":   time = lines[row].end
        case "text":  return lines[row].text
        default:      return nil
        }
        
        return String(describing: time)
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        //print(#function, info, row, dropOperation)
        return [.move]
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        //print(#function, info, row, dropOperation)
        let pboard = info.draggingPasteboard()
        guard let data = pboard.data(forType: LineWrapper.pasteboardType) else { return false }
        do {
            let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? LineWrapper
            guard
                let line = unarchived?.line,
                let oldIndex = lines.index(of: line)
                else { return false }
            
            tableView.beginUpdates()
            
            lines.moveElement(from: oldIndex, to: row)
            tableView.moveRow(at: oldIndex, to: row)
            
            tableView.endUpdates()
        } catch {
            print("deserialisation error:", error)
            return false
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        //print(#function, rowIndexes)
        guard let row = rowIndexes.first, lines.startIndex..<lines.endIndex ~= row else { return false }
        let linew = LineWrapper(lines[row])
        guard let data = linew.pasteboardPropertyList(forType: LineWrapper.pasteboardType) as? Data else {
            print("Couldn't serialise object")
            return false
        }
        pboard.setData(data, forType: LineWrapper.pasteboardType)
        return true
    }

}

//extension Subtitles: NSDraggingSource {}
