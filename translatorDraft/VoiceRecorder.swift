//
//  VoiceRecorder.swift
//  translatorDraft
//
//  Created by Aman Sahu on 7/9/24.
//

import SwiftUI
import AVFoundation
import Combine



/**
 The `VoiceRecording` class handles audio recording, playback, and translation functionalities.
 It uses `AVAudioRecorder` for recording and `AVAudioPlayer` for playback. It also manages audio file interactions and translations.
 */
class VoiceRecording: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    @Published var isRecordingVoice = false
    @Published var isPlayingAudio = false
    
    var cancellable: AnyCancellable?
    
    var timer: Timer?
    var silenceTimer: Timer?
    
    @AppStorage("languageDirection") var languageDirection: Bool = true
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let seamless_languages = ["English" :"eng", "Spanish":"spa", "Hindi":"hin", "Vietnamese": "vie",
                              "Greek":"ell", "Turkish":"tur", "German":"deu", "Italian":"ita", "Russian":"rus", "Arabic":"arb"]
    
    @Published var selectedSourceLanguage = "English"
    @Published var selectedTargetLanguage = "Spanish"
    
    public var sourceLanguageCode: String { languageDirection ? seamless_languages[selectedSourceLanguage]! : seamless_languages[selectedTargetLanguage]! }
    public var targetLanguageCode: String { languageDirection ? seamless_languages[selectedTargetLanguage]! : seamless_languages[selectedSourceLanguage]! }
    
    
    /**
     Starts recording audio and sets up necessary configurations.
     
     - Parameter completion: Closure called when silence is detected and recording is stopped.
     */
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
    
    
    /**
     Stops the audio recording and invalidates the timer.
     */
    func stopRecording() {
        print("Stopping Voice Recording")
        audioRecorder?.stop()
        isRecordingVoice = false
        timer?.invalidate()
        timer = nil
    }
    
    
    /**
     Checks the audio level and stops recording if silence is detected.
     
     - Parameter completion: Closure called when silence is detected and recording is stopped.
     */
    private func checkAudioLevel(completion: @escaping () -> Void) {
        audioRecorder?.updateMeters()
        
        guard let level = audioRecorder?.averagePower(forChannel: 0) else { return }
        
        print(level)
        
        if level < -35 {
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
    
    
    /**
     Retrieves and prints information about the recorded audio file.
     */
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
    
    
    /**
     Sends the recorded audio file to a server for translation and saves the translated file.
     */
    func translationAudioFile() {
        let recordingPath = paths[0].appendingPathComponent("recording.wav")
                
        guard FileManager.default.fileExists(atPath: recordingPath.path) else {
            print("Audio file does not exist at path: \(recordingPath.path)")
            return
        }
        
        //endpoint URL subject to change
        let url = URL(string: "http://localhost:8080/s2s")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //prep body data
        var body = Data()
        
        //append target lang code
        let tgtLang = targetLanguageCode
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"tgt_lang\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(tgtLang)\r\n".data(using: .utf8)!)
        
        //file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(recordingPath.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(try! Data(contentsOf: recordingPath))
        body.append("\r\n".data(using: .utf8)!)
        
        //close body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        //send request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send audio file: \(error)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Failed to get a valid response")
                return
            }
            
            //save returned audio file
            let translatedFilePath = self.paths[0].appendingPathComponent("translated_recording.wav")
            do {
                try data.write(to: translatedFilePath)
                print("Translated audio file saved at: \(translatedFilePath)")
                print("Now playing the audio file....")
                self.playTranslatedAudio()
            } catch {
                print("Failed to save translated audio file: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    /**
     Plays the translated audio file.
     */
    func playTranslatedAudio() {
        let translatedFilePath = paths[0].appendingPathComponent("translated_recording.wav")
        
        guard FileManager.default.fileExists(atPath: translatedFilePath.path) else {
            print("Translated audio file does not exist at path: \(translatedFilePath.path)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: translatedFilePath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlayingAudio = true
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }

    /**
     AVAudioPlayerDelegate method to handle audio playback completion
     */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlayingAudio = false
        print("Finished playing audio")
    }

    /**
     Converts the recorded audio file to an array of float values.
     
     - Returns: An array of `Float` values representing the audio data, or `nil` if conversion fails.
     */
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
            
            print(channelDataArray)
            return channelDataArray
            
        } catch {
            print("Failed to read audio file: \(error.localizedDescription)")
            return nil
        }
    }
    
}
