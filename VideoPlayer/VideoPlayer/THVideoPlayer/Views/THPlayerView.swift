//
//  THPlayerView.swift
//  VideoPlayer
//
//  Created by helloyako on 2017. 5. 28..
//  Copyright © 2017년 TapHarmonic, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class THPlayerView: UIView {
    private(set) var transport: THTransport?
    private var overlayView: THOverlayView?
    
    override var layer: CALayer {
        return AVPlayerLayer()
    }
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if let layer = self.layer as? AVPlayerLayer {
            layer.player = player
        }
        
        Bundle.main.loadNibNamed("THOverlayView", owner: self, options: nil)
        if let overlayView = self.overlayView {
            self.addSubview(overlayView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.overlayView?.frame = self.bounds
    }
    
    
    
}
