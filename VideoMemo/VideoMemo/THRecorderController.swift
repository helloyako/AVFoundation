//
//  THRecorderController.swift
//  VideoMemo
//
//  Created by helloyako on 2017. 5. 11..
//  Copyright © 2017년 helloyako. All rights reserved.
//

import AVFoundation

protocol THRecorderControllerDelegate {
    func interruptionBegan()
}

typealias THRecordingStopCompletionHandler = (Bool) -> ()
typealias THRecordingSaveCompletionHandler = (Bool, Any) -> ()

class THRecorderController: NSObject {
    
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    let meterTable = THMeterTable()
    var delegate: THRecorderControllerDelegate?
    var completionHandler: THRecordingStopCompletionHandler?
    var formattedCurrentTime: String {
        guard let recorder = self.recorder else {
            return "00:00:00"
        }
        let currentTime = Int(recorder.currentTime)
        let hours = currentTime / 3600
        let minutes = (currentTime / 60) % 60
        let seconds = currentTime % 60
        let format = "%.2i:%.2i:%.2i"
        return String(format: format, hours, minutes, seconds)
    }
    
    var levels: THLevelPair {
        recorder?.updateMeters()
        let avgPower = recorder?.averagePower(forChannel: 0) ?? 0.0
        let peakPower = recorder?.peakPower(forChannel: 0) ?? 0.0
        let linearLevel = meterTable.value(forPower: avgPower)
        let linearPeak = meterTable.value(forPower: peakPower)
        return THLevelPair(level: linearLevel, peakLevel: linearPeak)
    }
    var documentsDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    override init() {
        super.init()
        let tmpDir = NSTemporaryDirectory()
        var tmpUrl = URL(fileURLWithPath: tmpDir)
        tmpUrl.appendPathComponent("memo.caf")
        
        let settings: [String: Any] = [
            AVFormatIDKey : kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        recorder = try? AVAudioRecorder(url: tmpUrl, settings: settings)
        
        
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
    }
    
    func record() -> Bool {
        return recorder!.record()
    }
    
    func pause() {
        recorder?.pause()
    }
    
    func stop(completion: @escaping THRecordingStopCompletionHandler) {
        completionHandler = completion
        recorder?.stop()
    }
    
    func saveRecording(name: String, completion: THRecordingSaveCompletionHandler) {
        let timeStamp = Date.timeIntervalSinceReferenceDate
        let fileName = "\(name)-\(timeStamp).caf"
        
        let docDir = documentsDirectory
        var docURL = URL(fileURLWithPath: docDir)
    
        docURL.appendPathComponent(fileName)
        guard let srcURL = recorder?.url else {
            print("recorder url error")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: srcURL, to: docURL)
            completion(true, THMemo(title: name, url: docURL))
        } catch {
            print("file copy error")
        }
        
        
    }
    
    func playbackMemo(_ memo: THMemo) {
        player?.stop()
        do {
            player = try AVAudioPlayer(contentsOf: memo.url)
            player?.play()
        } catch {
            print("player error : \(error)")
        }
        
    }
}

extension THRecorderController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        completionHandler?(flag)
        
    }
}
