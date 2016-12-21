//
//  ViewController.swift
//  Scribe
//
//  Created by Geemakun Storey on 2016-12-19.
//  Copyright © 2016 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import Foundation

// Credit to these two tutorials that show developers how to setup Apple's Speech Framework
// Tutorial: https://www.youtube.com/watch?v=2gs5QTRC8Yk
// https://www.appcoda.com/siri-speech-framework/
// https://developer.apple.com/reference/speech

class ViewController: UIViewController, AVAudioPlayerDelegate, SFSpeechRecognizerDelegate {
   
    @IBOutlet weak var scribeTextView: UITextView!
    @IBOutlet weak var playButton: CircleButton!
    @IBOutlet weak var recordLabel: UILabel!
    
    // User Defaults
    let defaults = UserDefaults.standard

    // Authorize Speech
    let speechRecognizer  = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    // Responsivle for audio input
    let audioEngine = AVAudioEngine()
    
    // Array of colors
    var lowerColorsArray = lowerColors
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Transcriber"
        self.scribeTextView.text = "Tap the record button and say something. \nChange the background color by saying the color."
      
        // Userdefaults
       let savedColor =  UserDefaults.standard.color(forKey: "saveColor")
    
       view.backgroundColor = savedColor
       self.scribeTextView.backgroundColor = savedColor
        
        playButton.isEnabled = false
        
        speechRecognizer?.delegate = self
        
        requestAuthorization()
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            playButton.isEnabled = true
        } else {
            playButton.isEnabled = false
        }
    }
    
    func changeBackground(voiceString: String) {
        lowerCaseBackgroundChange(voice: voiceString)
    }
    
    func lowerCaseBackgroundChange(voice: String) {
        for color in lowerColorsArray {
            if voice.lowercased().range(of: color) != nil {
                var newColor = UIColor.white
                
                switch color {
                    case "blue": newColor = UIColor.blue
                    case "green": newColor = UIColor.green
                    case "red": newColor = UIColor.red
                    case "yellow": newColor = UIColor.yellow
                    case "black": newColor = UIColor.black
                    case "purple": newColor = UIColor.purple
                    case "orange": newColor = UIColor.orange
                    case "brown": newColor = UIColor.brown
                    case "silver": newColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
                    case "aqua": newColor = UIColor(red: 0/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
                    case "gold": newColor = UIColor(red: 255/255.0, green: 215/255.0, blue: 0/255.0, alpha: 1.0)
                    
                default: break
                }
                
                self.view.backgroundColor = newColor
                self.scribeTextView.backgroundColor = newColor
                
                UserDefaults.standard.set(newColor, forKey: "saveColor")
                
                let backGround = self.view.backgroundColor
                
                if backGround == UIColor.black {
                    scribeTextView.textColor = UIColor.white
                } else {
                    scribeTextView.textColor = UIColor.black
                }
                
            }
            
        }
    }
    
    @IBAction func playButton(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            playButton.isEnabled = false
           // playButton.setTitle("Start Recording", for: .normal)
            
        } else {
            startRecording()
            buttonStartedRecordingDesign()
        }
    }
    
    func buttonStartedRecordingDesign() {
        playButton.layer.borderWidth = 7
        playButton.backgroundColor = UIColor.white
        playButton.layer.borderColor = UIColor.white.cgColor
        recordLabel.text = "Recording..."
    }
    
    func buttonStoppedRecordingOriginalDesign() {
        // Reset the button and label
        self.playButton.layer.borderWidth = 0
        self.playButton.backgroundColor = UIColor.white
        self.playButton.isEnabled = true
        self.recordLabel.text = "Record"
    }
    
    func showAlert(title: String, message: String?, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
}


extension ViewController: SpeechAPIRequest {
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
        switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                self.showAlert(title: "Whoops!", message: "User denied access to speech recognition. Change in your device settings.")
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                self.showAlert(title: "Whoops!", message: "Speech recognition restricted on this device. Change in your device settings.")
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.playButton.isEnabled = isButtonEnabled
            }
        }
        
    }
}

extension ViewController: SpeechAPIStartRecording {
    func startRecording() {
        
        // Check if recognition task is running
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
        } catch {
            print("Audio properities not set")
            showAlert(title: "Oh no!", message: "Audio properities not set. Try again later.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio Engine has no input node...")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.scribeTextView.text = result?.bestTranscription.formattedString
              
                let lowerCasedResultString = result!.bestTranscription.formattedString.lowercased()
                print("Voice output: \(lowerCasedResultString)")
                
                // Setup change background
                self.changeBackground(voiceString: lowerCasedResultString)
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                
                // Reset the button and label
                self.buttonStoppedRecordingOriginalDesign()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            self.showAlert(title: "Whoops!", message: "Audio Engine didn't start. Try again later.")
            print("Audio Engine didn't start...")
        }
    }

}

