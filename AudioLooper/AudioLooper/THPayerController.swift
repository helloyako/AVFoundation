//
//  THPayerController.swift
//  AudioLooper
//
//  Created by helloyako on 2017. 5. 1..
//  Copyright © 2017년 helloyako. All rights reserved.
//

import Foundation
import AVFoundation

class THPlayerController {
    
    var players: [AVAudioPlayer] = []
    private(set) var isPlaying = false
    var delegate: THPlayerControllerDelegate?
    
    init() {
        guard let guitarPlayer = player(name: "guitar"), let bassPlayer = player(name: "bass"), let drumsPlayer = player(name: "drums") else {
            print("Can't make some AV Player")
            return
        }
        
        players = [guitarPlayer, bassPlayer, drumsPlayer]
        
        let notification = NotificationCenter.default
        
        notification.addObserver(self, selector: #selector(THPlayerController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        notification.addObserver(self, selector: #selector(THPlayerController.handleRouteChange(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let info = notification.userInfo else {
            print("info nil")
            return
        }
        
        guard let type = info[AVAudioSessionInterruptionTypeKey] as? UInt else {
            print("AVAudioSessionInterruptionTypeKey nil")
            return
        }
        
        if type == AVAudioSessionInterruptionType.began.rawValue {
            self.stop()
            self.delegate?.playbackStopped()
        } else {
            guard let options = info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                print("AVAudioSessionInterruptionOptionKey nil")
                return
            }
            
            if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
                self.play()
                self.delegate?.playbackBegan()
                
            }
        }
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let info = notification.userInfo else {
            print("info nil")
            return
        }
        
        guard let reason = info[AVAudioSessionRouteChangeReasonKey] as? UInt else {
            print("AVAudioSessionInterruptionTypeKey nil")
            return
        }
    
        if reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue {
            guard let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else {
                print("AVAudioSessionRouteDescription error")
                return
            }
            
        
            guard let previousOutput = previousRoute.outputs.first else {
                print("previousRout outputs first nil")
                return
            }
            
            let portType = previousOutput.portType
            
            if portType == AVAudioSessionPortHeadphones {
                DispatchQueue.main.async {
                    self.stop()
                    self.delegate?.playbackStopped()
                }
            }
        }
        
        
    }
    
    private func player(name: String) -> AVAudioPlayer? {
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: "caf") else {
            print("\(name) file URL error")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            
            player.numberOfLoops = -1 // loop indefinitely
            player.enableRate = true
            player.prepareToPlay()
            return player
        } catch {
            print("\(name) : \(error.localizedDescription)")
        }
        
        
        return nil
    }
    
    func play() {
        if !isPlaying {
            let delayTime = players[0].deviceCurrentTime + 0.01
            players.forEach {
                player in
                player.play(atTime: delayTime)
            }
            
            isPlaying = true
        }
    }
    
    func stop() {
        if isPlaying {
            players.forEach {
                player in
                player.stop()
                player.currentTime = 0
            }
            isPlaying = false
        }
        
    }
    
    func adjustRate(rate: Float) {
        players.forEach {
            player in
            player.rate = rate
        }
        
    }
    
    func adjustPan(pan: Float, index: Int) {
        if isValidIndex(index) {
            let player = players[index]
            player.pan = pan
        }
    }
    
    func adjustVolume(volume: Float, index: Int) {
        if isValidIndex(index) {
            let player = players[index]
            player.volume = volume
        }
        
    }
    
    private func isValidIndex(_ index: Int) -> Bool {
        return index == 0 || index < players.count
    }
}

protocol THPlayerControllerDelegate {
    func playbackStopped()
    func playbackBegan()
}
