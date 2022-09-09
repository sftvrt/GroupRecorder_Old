//
//  DataStorageManager.swift
//  Bachelorarbeit
//
//

import Foundation

struct DataStorageManager: Codable {
    
    // Enum for data error
    enum DataError: Error {
        case dataNotFound
        case dataNotSaved
    }
    
    let profileStorageURL: URL
    let documentURL: URL

    let recordingStorageURL: URL
    var kRecordingFiles = "RecordingFiles"
    var kprofileStorageInfo = "ProfileStorageInfo"

    init() {
        // Set up URLs
        documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let p_url = documentURL.appendingPathComponent("\(kprofileStorageInfo)", isDirectory: true)
        var p_isDirectory: ObjCBool = ObjCBool(false)
        let p_isExist = FileManager.default.fileExists(atPath: p_url.path, isDirectory: &p_isDirectory)
        if !p_isExist {
          do {
            try FileManager.default.createDirectory(at: p_url, withIntermediateDirectories: true, attributes: nil)
          } catch {
            print("createDirectory error:\(error)")
          }
        }
        
        profileStorageURL = p_url
        
        
        let url = documentURL.appendingPathComponent("\(kRecordingFiles)", isDirectory: true)
        var isDirectory: ObjCBool = ObjCBool(false)
        let isExist = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if !isExist {
          do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
          } catch {
            print("createDirectory error:\(error)")
          }
        }
        
        recordingStorageURL = url

    }
    
    // Store Data
    func storeProfiles(profiles: [Profile],name:String) throws {
        print("storeProfiles \(profiles.toJSONString())")
        let data = try JSONEncoder().encode(profiles)
        let dateString = self.dateFormatter().string(from: Date())
       let totleProfileeName = DataStorageManager().getStorageProfileInfoPathUrl(subPath: "\(name)\(dateString).txt")

        try writeData(data, to: totleProfileeName)
    }
    
    // Read Write Data
    func readData(from archive: URL) throws -> Data {
        if let data = try? Data(contentsOf: archive) {
            return data
        }
        throw DataError.dataNotFound
    }
    
    func writeData(_ data: Data, to archive: URL) throws {
        print("profileStorageURL \(archive)")
        do {
            try data.write(to: archive, options: .noFileProtection)
        }
        catch {
            throw DataError.dataNotSaved
        }
    }
    
    func getProfiles() throws -> [Profile] {
        let data = try readData(from: profileStorageURL)
        if let profile = try? JSONDecoder().decode([Profile].self, from: data) {
            return profile
        }
        throw DataError.dataNotFound
    }
    
    func getStorageRecordPathUrl(subPath: String) -> URL {
        let url = self.recordingStorageURL.appendingPathComponent("\(subPath)")
        return url
    }
    
    func getStorageProfileInfoPathUrl(subPath: String) -> URL {
        let url = self.profileStorageURL.appendingPathComponent("\(subPath)")
        return url
    }
    
    func dateFormatter() -> DateFormatter {
        let formatter =  DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return formatter
    }
}
