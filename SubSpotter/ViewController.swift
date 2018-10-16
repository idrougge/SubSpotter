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

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var tableView: NSTableView!
    
    var lines: [(time: TimeInterval, text: String)] = []
    
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

    @IBAction func raise(_ sender: NSMenuItem) {
        print(#function)
    }
    
    @IBAction func lower(_ sender: NSMenuItem) {
        print(#function)
    }
    
    @IBAction func didSelectOpen(_ sender: NSMenuItem) {
        print(#function, sender)
        let dialogue = NSOpenPanel()
        dialogue.allowsMultipleSelection = false
        dialogue.canChooseDirectories = false
        dialogue.allowedFileTypes = ["mp4", "m4v", "mpg", "avi", "mov", "mkv"]
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
            }
            
        }
    }
}

extension ViewController: NSTableViewDataSource {
    
}

extension ViewController: NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print(#function)
        return lines.count
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        //print(#function, row)
        //return "\(tableColumn?.identifier.rawValue): \(row)"
        switch tableColumn?.identifier.rawValue {
        case "time": return lines[row].time
        case "text": return lines[row].text
        default: return nil
        }
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
