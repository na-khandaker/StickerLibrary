//
//  SMFileManager.swift
//  StickerMakerNew4.0
//
//  Created by Bcl Device 13 on 3/11/24.
//

import Foundation
//import Zip
import UIKit
import YYImage

class SMFileManager {
    static let shared = SMFileManager()
    
    let fileManager = FileManager.default
    lazy var documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    lazy var categoryDirectory = documentDirectory.appendingPathComponent("categoryThumbDirectory/")
    lazy var packDirectory = documentDirectory.appendingPathComponent("BCStickerPacks/")

    lazy var bcAssetsDirectory = documentDirectory.appendingPathComponent("BCAssets/")
    var tmpDirectory: [String] {
        return try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
    }
    
    
    func clearTmpDirectory() throws {
        try tmpDirectory.forEach {[unowned self] file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try fileManager.removeItem(atPath: path)
        }
    }
    
    private func clearAllFiles(completion: @escaping (_ success: Bool) -> Void) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        print("Directory: \(paths)")
        
        do {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
            
            for file in fileName {
                print("Deleting file: ",file)
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
            completion(true)
        } catch let error {
            print(error)
            completion(false)
        }
    }
    

    
    func getFilePath(for subDirectory: String?) -> String? {
        return documentDirectory.appendingPathComponent(subDirectory ?? "").path
    }
    
    func getFileURL(for subDirectory: String?) -> URL? {
        return documentDirectory.appendingPathComponent(subDirectory ?? "")
    }
    
    func isFileExists(at path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
    
    func createNewFolder(folderName: String, at directory: URL) -> URL? {
        
        var isSuccess = false
        let folderURL = directory.appendingPathComponent(folderName)
        
        if !self.isFileExists(at: folderURL.path) {
            isSuccess = self.createDirectory(at: folderURL.path)
        } else {
            isSuccess = true
        }
        return isSuccess ? folderURL : nil
    }
    
    private func createDirectory(at path: String) -> Bool {
        var isSuccess = false
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            isSuccess = true
        } catch {
            print(error.localizedDescription);
            isSuccess = false
        }
        return isSuccess
    }
    
    func getPatternImageThumb(for name: String) -> UIImage? {
        let filePath = self.bcAssetsDirectory.appendingPathComponent("Pattern/Thumb/\(name)")
        return UIImage(contentsOfFile: filePath.path)
    }
    
    func getPatternImageMain(for name: String) -> UIImage? {
        let filePath = self.bcAssetsDirectory.appendingPathComponent("Pattern/Main/\(name)")
        return UIImage(contentsOfFile: filePath.path)
    }
    
    func getFilePathForGroup(with subDir: String?) -> URL? {
        return nil
    }
}
