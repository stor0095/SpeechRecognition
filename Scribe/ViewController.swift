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

// Credit to devslopes for this tutorial, showing us how to setup and use 
// Apple's voice recognition
// Tutorial: https://www.youtube.com/watch?v=2gs5QTRC8Yk

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var scribeTextView: UITextView!
    @IBOutlet weak var playButton: CircleButton!
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Transcriber"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        // When audio has stopped playing, hide the spinner and enable button again
        //activWheel.stopAnimating()
       // activWheel.isHidden = true
        playButton.isEnabled = true
    }
    
    func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                // Set up path to audio file and analyze it
                if let path = Bundle.main.url(forResource: "DateAudio", withExtension: "m4a") {
                    do {
                        // Play audio
                        let sound = try AVAudioPlayer(contentsOf: path)
                        self.audioPlayer = sound
                        // Setup delegate
                        self.audioPlayer.delegate = self
                        sound.play()
                    } catch {
                        print("Error")
                    }
                    // Apple Speech API: https://developer.apple.com/reference/speech
                    // Set up recognizer
                    let recognizer = SFSpeechRecognizer()
                    // Create request that pulls file
                    let request = SFSpeechURLRecognitionRequest(url: path)
                    // Recognize text and print the result
                    recognizer?.recognitionTask(with: request) {(result, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            self.scribeTextView.text = result?.bestTranscription.formattedString
                            // Log to console
                            print("Output: \(result!.bestTranscription.formattedString)")
                            
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func playButton(_ sender: AnyObject) {
       // activWheel.isHidden = false
       // activWheel.startAnimating()
        playButton.isEnabled = false
        
        requestSpeechAuth()
    }
    
    



}

