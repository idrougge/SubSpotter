//
//  PlayerView.swift
//  SubSpotter
//
//  Created by Iggy Drougge on 2018-10-17.
//  Copyright © 2018 Iggy Drougge. All rights reserved.
//

import AVKit

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
