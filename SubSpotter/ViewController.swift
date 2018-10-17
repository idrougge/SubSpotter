//
//  ViewController.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-15.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    //fileprivate typealias Line = (start: CMTime, end: CMTime, text: String)
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var tableView: NSTableView!
    
    private var staged: Line?
    private var lines: [Line] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            let url = URL(fileURLWithPath: "/Users/Iggy/Downloads/big_buck_bunny.mp4")
            openNewFile(from: url)
        #endif
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerForDraggedTypes([LineWrapper.pasteboardType])
        playerView.playerLayer.player = AVPlayer()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func keyUp(with event: NSEvent) {
        //print(#function, event)
        switch event.keyCode {
        case 49: stage() // 49 = space
        default: return
        }
    }
    
    private func stage() {
        guard let player = playerView.player
            else { return }
        commit()
        
        let startTime = player.currentTime()
        let secondsToShow: TimeInterval = 3 // Should be calculated according to text length + K
        let endTime = startTime + secondsToShow
        staged = Line(start: startTime, end: endTime, text: "En textrad")
    }

    private func commit() {
        guard
            let staged = staged,
            let player = playerView.player
            else { return }
        let endTime = player.currentTime()
        let line = Line(start: staged.start, end: endTime, text: staged.text)
        let index = lines.endIndex
        lines.append(line)
        tableView.reloadData()
        tableView.scrollRowToVisible(index)
        self.staged = nil
    }
    
    @IBAction func raise(_ sender: NSMenuItem) {
        print(#function)
        stage()
    }
    
    @IBAction func lower(_ sender: NSMenuItem) {
        print(#function)
        commit()
    }

    @IBAction func didSelectOpen(_ sender: NSMenuItem) {
        print(#function, sender)
        let dialogue = NSOpenPanel()
        dialogue.allowsMultipleSelection = false
        dialogue.canChooseDirectories = false
        dialogue.allowedFileTypes = ["mp4", "m4v", "mpg", "mpeg", "avi", "mov", "mkv"]
        guard dialogue.runModal() == .OK, let url = dialogue.url else { return }
        openNewFile(from: url)
    }
    
    func openNewFile(from url:URL) {
        print(#function, url)
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]){
            DispatchQueue.main.async {
                print("loaded values for", asset)
                print("metadata:", asset.metadata)
                print("duration:", asset.overallDurationHint, asset.duration)
                print("tracks:", asset.tracks, asset.trackGroups)
                print("characteristics:", asset.availableMediaCharacteristicsWithMediaSelectionOptions)
                guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else { return print("No video") }
                let fps = videoTrack.nominalFrameRate
                print("fps:", fps, "interval:", Double(1/fps))
                let item = AVPlayerItem(asset: asset)
                let player = self.playerView.player
                player?.replaceCurrentItem(with: item)
                player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: TimeInterval(frames: fps), preferredTimescale: 600), queue: .main){ time in
                    //print("periodic:", time.seconds, time.value, player!.currentTime().value)
                    if let endTime = self.staged?.end, time >= endTime {
                        self.commit()
                    }
                }
                player?.play()
                #if DEBUG
                player?.isMuted = true
                #endif
            }
            
        }
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
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
        
        return String(format: "%06.3f", time.seconds)
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        //print(#function, info, row, dropOperation)
        return [.move]
    }
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        print(#function, info, row, dropOperation)
        let pboard = info.draggingPasteboard()
        guard let data = pboard.data(forType: LineWrapper.pasteboardType) else { return false }
        do {
            let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? LineWrapper
            guard let line = unarchived?.line else { return false }
            guard let oldIndex = lines.index(of: line) else { return false }
            tableView.beginUpdates()
            lines.insert(line, at: row)
            if oldIndex < row {
                lines.remove(at: oldIndex)
            } else {
                lines.remove(at: oldIndex.advanced(by: 1))
            }
            tableView.moveRow(at: oldIndex, to: row)
            tableView.endUpdates()
        } catch {
            print("deserialisation error:", error)
            return false
        }
        return true
    }
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        print(#function, rowIndexes)
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
