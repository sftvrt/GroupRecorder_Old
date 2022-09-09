//
//  showFiles.swift
//  Bachelorarbeit
//
//  Created by JT X on 05.08.22.
//


import SwiftUI

struct showFiles: View {
    @EnvironmentObject var rootVM: RootViewModel
    
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    var body: some View {
        VStack{
            /*
            HStack{
                Text("AudioURL")
                Button(action: {
                }, label: {
                    Image(systemName:  "play")
                })
                Button(action: {
                }, label: {
                    Image(systemName:  "square.and.arrow.up")
                })
            }
            */
            Spacer()
            RecordingList(audioRecorder: audioRecorder)
            
        }
        .onAppear {
    
            audioRecorder.fetchRecordings()

        }.onReceive(NotificationCenter.default.publisher(for: .refreshNavigationBar)) { (notif) in
            let index:Int = notif.object as! Int
            // 刷新导航栏
            if index == 2 {
                self.rootVM.tabNavigationHidden = false
                self.rootVM.tabNavigationTitle = ""
                self.rootVM.tabNavigationBarLeadingItems = .init(EmptyView())
                self.rootVM.tabNavigationBarTrailingItems = .init(EmptyView())
            }
           
        }
    }
}
