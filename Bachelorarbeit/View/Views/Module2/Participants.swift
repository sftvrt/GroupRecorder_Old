//
//  Participants.swift
//  Bachelorarbeit
//
//  Created by 刘小坤 on 2022/8/15.
//

import SwiftUI
import MultipeerConnectivity

struct Participants: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State var currentUrl: URL?
    
    func setupRow(displayName:String) -> some View {
        let online = self.audioRecorder.nearbyService.connectedNames.contains(displayName)
       return HStack{
           Button(action: {
           }, label: {
               Image(systemName: online ? "person.fill.checkmark" : "person.fill.xmark")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 30, height: 30)
                   .foregroundColor(online ? .green : .red)
           })
           
           VStack {
               Text("\(displayName)")
                   .padding()
           }
       }
    }
    
    var body: some View {
        let t_connectHistoryNames = Array(self.audioRecorder.nearbyService.connectHistoryNames)
        List{
            ForEach(t_connectHistoryNames , id: \.self){ displayName in
                setupRow(displayName: displayName)
            }
        }
    }
}

struct Participants_Previews: PreviewProvider {
    static var previews: some View {
        Participants(audioRecorder: AudioRecorder(NearbyService(displayName: "",UserData())))
    }
}
