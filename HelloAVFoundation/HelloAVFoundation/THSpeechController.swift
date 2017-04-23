//
//  THSpeechController.swift
//  Chapter1
//
//  Created by helloyako on 2017. 4. 23..
//  Copyright © 2017년 helloyako. All rights reserved.
//

import AVFoundation

class THSpeechController: NSObject {
    static let shared = THSpeechController()
    let synthesizer = AVSpeechSynthesizer()
    var voices = [AVSpeechSynthesisVoice(language: "en-US"), AVSpeechSynthesisVoice(language: "en-GB")]
    var speechStrings: [String] = []
    
    private override init() {
        super.init()
        speechStrings = buildSpeechStrings()
    }
    
    func buildSpeechStrings() -> [String] {
        return ["Hello AV Foundation. How are you?",
                 "I'm well!  Thanks for asking.",
                 "Are you excited about the book?",
                 "Very! I have always felt so misunderstood",
                 "What's your favorite feature?",
                 "Oh, they're all my babies. I couldn't possibly choose.",
                 "It was great to speak with you!",
                 "The pleasure was all mine!  Have fun!"]
    }
    
    func beginConversation() {
        for (index, string) in self.speechStrings.enumerated() {
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = voices[index % 2]
            utterance.rate = 0.4
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.1
            synthesizer.speak(utterance)
        }
    }
}

