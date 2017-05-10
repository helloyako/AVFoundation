//
//  ViewController.swift
//  AudioLooper
//
//  Created by helloyako on 2017. 5. 1..
//  Copyright © 2017년 helloyako. All rights reserved.
//

import UIKit

class ViewController: UIViewController, THPlayerControllerDelegate {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var rateKnob: THControlKnob!
    let controller = THPlayerController()
    @IBOutlet var panknobs: [THControlKnob]!
    @IBOutlet var volumeKnobs: [THControlKnob]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        controller.delegate = self
        
        rateKnob.minimumValue = 0.5
        rateKnob.maximumValue = 1.5
        rateKnob.value = 1.0
        rateKnob.defaultValue = 1.0
        
        panknobs.forEach {
            knob in
            knob.minimumValue = -1.0
            knob.maximumValue = 1.0
            knob.value = 0.0
            knob.defaultValue = 0.0
        }
        
        volumeKnobs.forEach {
            knob in
            knob.minimumValue = 0.0
            knob.maximumValue = 1.0
            knob.value = 1.0
            knob.defaultValue = 1.0
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func play(_ sender: UIButton) {
        if controller.isPlaying {
            controller.stop()
            playLabel.text = "Play"
        } else {
            controller.play()
            playLabel.text = "Stop"
        }
        playButton.isSelected = !playButton.isSelected
    }
    
    @IBAction func adjustRate(_ sender: THControlKnob) {
        controller.adjustRate(rate: sender.value)
    }
    
    @IBAction func adjustPan(_ sender: THControlKnob) {
        controller.adjustPan(pan: sender.value, index: sender.tag)
    }
    
    @IBAction func adjustVolume(_ sender: THControlKnob) {
        controller.adjustVolume(volume: sender.value, index: sender.tag)
    }
    
    func playbackBegan() {
        playButton.isSelected = true
        playLabel.text = "Stop"
    }
    
    func playbackStopped() {
        playButton.isSelected = false
        playLabel.text = "Play"
        
    }

}

