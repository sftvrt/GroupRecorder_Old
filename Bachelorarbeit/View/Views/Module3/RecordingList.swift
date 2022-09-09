//
//  RecordingList.swift
//  AudioRecorder
//
//   Created by JT X on 16.11.20.
//  
//

import SwiftUI

struct RecordingList: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State var currentUrl: URL?
    
    var body: some View {
        List{
            ForEach(self.audioRecorder.recordings , id: \.createdAt){ recording in
                RecordingRow(audioURL: recording.fileURL, currentUrl: $currentUrl)  
            }
            .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(audioRecorder.recordings[index].fileURL)
        }

        audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
    }
}

struct RecordingList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingList(audioRecorder: AudioRecorder(NearbyService(displayName: "",UserData())))
    }
}
