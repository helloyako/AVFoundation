//
//  ViewController.swift
//  HelloAVFoundation
//
//  Created by helloyako on 2017. 4. 23..
//  Copyright © 2017년 helloyako. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        THSpeechController.shared.beginConversation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

