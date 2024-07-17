//
//  VoiceRecorder.swift
//  translatorDraft
//
//  Created by Aman Sahu on 7/9/24.
//

import SwiftUI
import AVFoundation

class VoiceRecording: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    var isRecordingVoice = false
    var timer: Timer?
    var silenceTimer: Timer?
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    func startRecording(completion: @escaping () -> Void) {
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
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecordingVoice = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.checkAudioLevel(completion: completion)
            }
            
            
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    
    func stopRecording() {
        print("Stopping Voice Recording")
        audioRecorder?.stop()
        isRecordingVoice = false
        timer?.invalidate()
        timer = nil
    }
    
    private func checkAudioLevel(completion: @escaping () -> Void) {
        audioRecorder?.updateMeters()
        
        guard let level = audioRecorder?.averagePower(forChannel: 0) else { return }
        
        print(level)
        
        if level < -40 {
            if silenceTimer == nil {
                silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                    self?.stopRecording()
                    self?.silenceTimer = nil
                    completion()
                }
            }
        } else {
            silenceTimer?.invalidate()
            silenceTimer = nil
        }
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
    
    func audioFileToArray() -> [Float]? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let recordingPath = paths[0].appendingPathComponent("recording.wav")
        
        do {
            let file = try AVAudioFile(forReading: recordingPath)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                print("Failed to create buffer")
                return nil
            }
            
            try file.read(into: buffer, frameCount: frameCount)
            
            guard let channelData = buffer.floatChannelData else {
                print("No channel data found")
                return nil
            }
            
            let channelDataPointer = channelData.pointee
            let channelDataArray = Array(UnsafeBufferPointer(start: channelDataPointer, count: Int(buffer.frameLength)))
            
            return channelDataArray
            
        } catch {
            print("Failed to read audio file: \(error.localizedDescription)")
            return nil
        }
    }
    
}
