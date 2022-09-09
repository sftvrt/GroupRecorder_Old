//
//  RecordingRow.swift
//  AudioRecorder
//
//   Created by JT X on 16.11.20.
//
//

import SwiftUI

struct RecordingRow: View {
    var audioURL: URL
    @EnvironmentObject var audioPlayer: AudioRecorder
    @Binding var url: URL?
    @StateObject var loginVM = LoginViewModel()
    @StateObject var uploadVM = uploadViewModel()
    @State var webService = Webservice()
    
    init(audioURL: URL , currentUrl: Binding<URL?>) {
        self.audioURL = audioURL
        self._url = currentUrl
    }
    
    var body: some View {
        HStack{
        VStack {
            Text("\(audioURL.lastPathComponent)")
        }
            HStack{
                /*
                Button(action: {
                    if audioPlayer.asset?.url == audioURL && audioPlayer.isPlay {
                        audioPlayer.pasue()
                    } else {
                        audioPlayer.play(audioURL)
                    }
                }, label: {
                    Image(systemName: (audioPlayer.asset?.url == audioURL && audioPlayer.isPlay) ? "pause" : "play")
                   //     .resizable()
                   //     .aspectRatio(contentMode: .fit)
                  //      .frame(width: 20, height: 20)
                  
          
                })
                */
                
                    
                    Button(action: {
                        loginVM.login()
                        if loginVM.isAuthenticated == true {
                            let defaults = UserDefaults.standard
                            guard let token = defaults.string(forKey: "jsonwebtoken") else {
                                return
                            }
                            webService.uploadAudios(token: token, audioURL: audioURL)
                        }
                        
                    }, label: {
                        Image(systemName:  "square.and.arrow.up")
                    })
                
            }
      
    }
    }
    

    struct RecordingRow_Previews: PreviewProvider {
        static var previews: some View {
            /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
        }
    }
}
