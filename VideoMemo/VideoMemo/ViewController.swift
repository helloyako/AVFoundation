//
//  ViewController.swift
//  VideoMemo
//
//  Created by helloyako on 2017. 5. 11..
//  Copyright © 2017년 helloyako. All rights reserved.
//

import UIKit

let MEMOS_ARCHIVE = "memos.archive"
let MEMO_CELL = "memoCell"
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var levelMeterView: THLevelMeterView!
    
    let controller = THRecorderController()
    var memos: [THMemo] = []
    var timer: Timer?
    var levelTimer: CADisplayLink?
    
    var archiveURL: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = paths[0]
        let archivePath = docsDir + MEMOS_ARCHIVE
        return URL(fileURLWithPath: archivePath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        controller.delegate = self
        stopButton.isEnabled = false
        
        do {
            let data = try Data(contentsOf: archiveURL)
            if let memos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [THMemo] {
                self.memos = memos
            }
        } catch {
            print("Data contentsOf cathed \(error)")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func record(_ sender: UIButton) {
        self.stopButton.isEnabled = true
        if sender.isSelected {
            stopMeterTimer()
            stopTimer()
            controller.pause()
        } else {
            startMeterTimer()
            startTimer()
            _ = controller.record()
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        stopMeterTimer()
        recordButton.isSelected = false
        stopButton.isEnabled = false
        
        controller.stop {
            result in
            let delayInSeconds = 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                self.showSaveDialog()
            }
        }
        
        
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        levelTimer?.preferredFramesPerSecond = 5
        levelTimer?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func stopMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        levelMeterView.resetLevelMeter()
    }
    
    func updateTimeDisplay() {
        timeLabel.text = controller.formattedCurrentTime
    }
    
    func updateMeter() {
        let levels = controller.levels
        levelMeterView.level = CGFloat(levels.level)
        levelMeterView.peakLevel = CGFloat(levels.peakLevel)
        levelMeterView.setNeedsDisplay()
    }
    
    func showSaveDialog() {
        let alertController = UIAlertController(title: "Save Recording", message: "Please provide a nmae", preferredStyle: .alert)
        alertController.addTextField {
            textField in
            textField.placeholder = "My Recording"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in
            let fileName = alertController.textFields?.first?.text ?? ""
            self.controller.saveRecording(name: fileName) {
                success, memo in
                guard let memo = memo as? THMemo else {
                    return
                }
                if success {
                    self.memos.append(memo)
                    self.saveMemos()
                    self.tableView.reloadData()
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveMemos() {
        let fileData = NSKeyedArchiver.archivedData(withRootObject: self.memos)
        try? fileData.write(to: archiveURL, options: .atomicWrite)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MEMO_CELL, for: indexPath)
        if let cell = cell as? THMemoCell {
            let memo = memos[indexPath.row]
            cell.titleLabel.text = memo.title
            cell.dateLabel.text = memo.dateString
            cell.timeLabel.text = memo.timeString
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memo = memos[indexPath.row]
            memo.delete()
            memos.remove(at: indexPath.row)
            saveMemos()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        controller.playbackMemo(memo)
    }
    
    
}

extension ViewController: THRecorderControllerDelegate {
    func interruptionBegan() {
        recordButton.isSelected = false
        stopMeterTimer()
        stopTimer()
    }
}
