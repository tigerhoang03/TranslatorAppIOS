//
//  textFileHandler.swift
//  translatorDraft
//
//  Created by Aman Sahu on 8/9/24.
//

import Foundation

class TextFileHandler: ObservableObject {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    //create a file and its URL
    func createFileURL(fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = "".data(using: .utf8)!
                try data.write(to: fileURL)
                print("File created successfully!")
            } catch {
                print("Error creating file: \(error)")
            }
        } else {
            print("File already exists")
        }

        return fileURL
    }


    //write text to file
    func appendTextToFile(text: String, fileURL: URL) -> Bool {
      guard let data = text.data(using: .utf8) else {
        print("Failed to convert text to data.")
        return false
      }

      // Open the file for appending (if it exists) or creating (if it doesn't)
      if let fileHandle = try? FileHandle(forUpdating: fileURL) {
        // Seek to the end of the file before writing
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
        fileHandle.closeFile()
        print("Text appended to: \(fileURL)")
        return true
      } else {
        // Create the file if it doesn't exist
        do {
          try data.write(to: fileURL)
          print("File created and data written: \(fileURL)")
          return true
        } catch {
          print("Error creating/writing to file: \(error)")
          return false
        }
      }
    }

}
