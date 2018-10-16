//
//  ViewController.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-15.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class ViewController: NSViewController {

    private typealias Line = (start: CMTime, end: CMTime, text: String)
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var tableView: NSTableView!
    
    private var staged: (start: CMTime, text: String)?
    private var lines: [Line] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            let url = URL(fileURLWithPath: "/Users/Iggy/Downloads/big_buck_bunny.mp4")
            openNewFile(from: url)
        #endif
        
        tableView.delegate = self
        tableView.dataSource = self
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
        case 49: stage()
        default: return
        }
    }
    
    private func stage() {
        guard let player = playerView.player
            else { return }
        commit()
        let time = player.currentTime()
        staged = (start: time, text: "En textrad")
    }

    private func commit() {
        guard
            let staged = staged,
            let player = playerView.player
            else { return }
        let endTime = player.currentTime()
        let line: Line = (start: staged.start, end: endTime, text: staged.text)
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
                let item = AVPlayerItem(asset: asset)
                let player = self.playerView.player
                player?.replaceCurrentItem(with: item)
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
        
        let s = Int(time.seconds)
        let ms = time.seconds.truncatingRemainder(dividingBy: 1)
        return String(format: "%06.3f", time.seconds)
    }
}

/// Use instead of standard AVPlayerView in order to avoid standard keyboard shortcuts and player controls
class PlayerView: NSView {
    // TODO: Implement scrubber and playback controls separately
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.layer = AVPlayerLayer()
    }
    
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        return playerLayer.player
    }
}
