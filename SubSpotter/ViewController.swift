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
    
    var subtitles: Subtitles = Subtitles()
    
    /// Full path to current file
    var path: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
            let url = URL(fileURLWithPath: "/Users/Iggy/Downloads/big_buck_bunny.mp4")
            openNewFile(from: url)
        #endif
        
        //tableView.delegate = self
        tableView.dataSource = subtitles
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
        subtitles.stage(text: subtitles.nextLine, at: startTime)
    }

    private func commit() {
        guard let player = playerView.player
            else { return }
        
        let index = subtitles.commit(at: player.currentTime())
        
        tableView.reloadData()
        tableView.scrollRowToVisible(index)
    }
    
    @IBAction func raise(_ sender: NSMenuItem) {
        print(#function)
        stage()
    }
    
    @IBAction func lower(_ sender: NSMenuItem) {
        //print(#function)
        commit()
    }

    @IBAction func didSelectOpenVideo(_ sender: NSMenuItem) {
        let dialogue = NSOpenPanel()
        dialogue.allowsMultipleSelection = false
        dialogue.canChooseDirectories = false
        dialogue.allowedFileTypes = ["mp4", "m4v", "mpg", "mpeg", "avi", "mov", "mkv"]
        guard dialogue.runModal() == .OK, let url = dialogue.url else { return }
        openNewFile(from: url)
    }
    
    @IBAction func didSelectOpenText(_ sender: NSMenuItem) {
        let dialogue = NSOpenPanel()
        dialogue.allowsMultipleSelection = false
        dialogue.canChooseDirectories = false
        dialogue.allowedFileTypes = ["rtfd", "rtf", "txt", "doc", "docx"]
        guard dialogue.runModal() == .OK, let url = dialogue.url else { return }
        openText(from: url)
    }
    
    @IBAction func didSelectSave(_ sender: NSMenuItem) {
        print(#function)
        let suffix = "srt"
        let dialogue = NSSavePanel()
        dialogue.directoryURL = path?.deletingLastPathComponent()
        if let filename = path?.deletingPathExtension().appendingPathExtension(suffix).lastPathComponent {
            dialogue.nameFieldStringValue = filename
        }
        guard dialogue.runModal() == .OK, let url = dialogue.url else { return print("Save error") }
        print("saving to:", url)
        do {
            try subtitles.export(to: url, using: SrtExporter.self)
        } catch {
            presentError(error)
        }
    }
    
    func openText(from url: URL) {
        do {
            try subtitles.importText(from: url, using: TextImporter())
        } catch {
            presentError(error)
        }
    }
    
    func openNewFile(from url:URL) {
        print(#function, url)
        let asset = AVAsset(url: url)
        path = url
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
                player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: TimeInterval(frames: fps), preferredTimescale: 600), queue: .main){ [weak self] time in
                    //print("periodic:", time.seconds, time.value, player!.currentTime().value)
                    self?.subtitles.currentTime = time
                    self?.subtitles.commit{ index in
                        self?.tableView.reloadData()
                        self?.tableView.scrollRowToVisible(index)
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
