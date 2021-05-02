//
//  ViewController.swift
//  Sound Recorder App
//
//  Created by Kyle Sherrington on 2021-05-02.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var recordingSession: AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    let settings = [AVFormatIDKey:Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
    
    let sounds = ["a", "b", "c", "d"]
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add long press gesture recognizer to buttons
        let longPressRecognizerA = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonA.addGestureRecognizer(longPressRecognizerA)
        
        let longPressRecognizerB = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonB.addGestureRecognizer(longPressRecognizerB)
        
        let longPressRecognizerC = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonC.addGestureRecognizer(longPressRecognizerC)
        
        let longPressRecognizerD = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        buttonD.addGestureRecognizer(longPressRecognizerD)
        
        
        // create shared instance
        recordingSession = AVAudioSession.sharedInstance()
        
        // get user permission to record
        AVAudioSession.sharedInstance().requestRecordPermission {
            (accepted) in
            if accepted {
                print("Permission granted")
            }
        }
    }
    
    // MARK: - Methods
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        let button = sender.view as? UIButton
        let tag = sender.view!.tag
        
        if sender.state == .began {
            button?.setTitle("Recording...", for: .normal)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
                try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                
                let filename = getDirectory().appendingPathComponent("\(tag).m4a")
                
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.record()
            }
            catch {
                print("Failed to record")
            }
            
        } else if sender.state == .ended {
            button?.setTitle("Play", for: .normal)
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    // return location of directory of iPhone
    func getDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        let tag = sender.tag
        let path = getDirectory().appendingPathComponent("\(tag).m4a").path
        
        if FileManager.default.fileExists(atPath: path) {
            
            // play recorded file
            let filePath = getDirectory().appendingPathComponent("\(tag).m4a")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                audioPlayer.play()
                
            }
            catch {
                print("Failed to play file")
            }
            
        } else {
            
            let url = Bundle.main.url(forResource: sounds[sender.tag], withExtension: "mp3")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer.play()
            }
            catch {
                print("Failed to play")
            }
        }
    }
}
