//
//  RecordingDataModel.swift
//  AudioRecorder
//
//   Created by JT X on 16.11.20.
//
//

import Foundation

struct Recording : Comparable{
    static func < (lhs: Recording, rhs: Recording) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    let fileURL: URL
    let createdAt: Date 
}
