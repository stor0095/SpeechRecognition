//
//  SpeechAPI.swift
//  Scribe
//
//  Created by Geemakun Storey on 2016-12-20.
//  Copyright © 2016 geemakunstorey@storeyofgee.com. All rights reserved.
//

protocol SpeechAPIRequest {
    func requestAuthorization()
}

protocol SpeechAPIStartRecording {
    func startRecording()
}
