//
//  premiumViewModel.swift
//  translatorDraft
//
//  Created by Aman Sahu on 7/9/24.
//

import SwiftUI
import AVFoundation

class premiumViewModel: NSObject, ObservableObject {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 16000.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false
            ]
            
            let url = paths[0].appendingPathComponent("recording.wav")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    func getAudioInfo() {
        let recordingPath = paths[0].appendingPathComponent("recording.wav")
        
        if !FileManager.default.fileExists(atPath: recordingPath.path) {
            print("Audio file does not exist at path: \(recordingPath.path)")
        }
        
        do{
            let file = try AVAudioFile(forReading: recordingPath)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            
            print("File URL: \(recordingPath)")
            print("Audio file format: \(format)")
            print("Sample rate: \(format.sampleRate)")
            print("Channel count: \(format.channelCount)")
            print("Number of frames: \(frameCount)")
        }
        catch {
            print("Failed to read audio file: \(error.localizedDescription)")
        }
    }
}

extension premiumViewModel: AVAudioRecorderDelegate {}
