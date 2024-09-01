//
//  textFileHandler.swift
//  translatorDraft
//
//  Created by Aman Sahu on 8/9/24.
//

import Foundation


/**
 The `TextFileHandler` class provides methods for creating and managing text files in the documents directory.
 It allows you to create a file and append text to it.
 */
class TextFileHandler: ObservableObject {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    /**
     Creates a file with the specified name in the documents directory.
     
     - Parameter fileName: The name of the file to be created.
     - Returns: The URL of the created file.
     */
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


    /**
     Appends the specified text to the file at the given URL.
     If the file does not exist, it creates the file and writes the text.
     
     - Parameters:
        - text: The text to append to the file.
        - fileURL: The URL of the file to which the text will be appended.
     - Returns: `true` if the text was successfully appended or the file was created and written to; otherwise, `false`.
     */
    func appendTextToFile(text: String, fileURL: URL) -> Bool {
      guard let data = text.data(using: .utf8) else {
        print("Failed to convert text to data.")
        return false
      }

      // if file exists, open for appending, otherwise create file to append
      if let fileHandle = try? FileHandle(forUpdating: fileURL) {
        // seek to end of the file before writing
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
        fileHandle.closeFile()
        print("Text appended to: \(fileURL)")
        return true
      } else {
        // create file if it doesn't exist
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
