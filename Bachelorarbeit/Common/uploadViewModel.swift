//
//  uploadViewModel.swift
//  Bachelorarbeit
//
//  Created by JT X on 18.08.22.
//


// Version 1

import Foundation
class uploadViewModel: ObservableObject{
    
    let uploadUrl = "https://clarin.phonetik.uni-muenchen.de/webapps/octra-api-dev/v1/projects/1/tasks"
    
    func getTestAudioUrl()-> URL {
        guard let filePathFive = Bundle.main .path(forResource: "testAudio", ofType: "wav") else { return URL.init(fileURLWithPath: "") }
        return URL.init(fileURLWithPath: filePathFive)
    }
    
  //  let audioUrl = URL(string: "/Users/jtx/Downloads/new_app_try/newApp/Bachelorarbeit/aaa.wav")!
//    let audioUrl : URL
   
    /*
    init(audioUrl: URL) {
        self.audioUrl = audioUrl
        }
    */
    

   // let audioData = try! Data(contentsOf: audioUrl)
    
    
    
    
   
    
    
  

        
     
     /*
        Webservice().uploadAudios(accessToken:token) {
            (result) in
            switch result{
            case .success(let dictionary):
                print(dictionary)
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
        */
    
    func UploadAudioFiles(){
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: "jsonwebtoken") else {
            return
        }
   //     Webservice().uploadAudios(token:token, audioURL:URL)
    }
        
    }
    
