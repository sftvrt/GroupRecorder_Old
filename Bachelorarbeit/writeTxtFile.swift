//
//  writeTxtFile.swift
//  Bachelorarbeit
//
//  Created by JT X on 19.05.22.
//

/*
import Foundation

//import Cocoa
class writTxtfile {
let file = "file.txt" //this is the file. we will write to and read from it
   
    
let text = "some text" //just a text
    var profile: Profile
    
    @Published var profile: Profile = Profile(username: "", Alter: "", regionaleHerkunft: " ")
    
    init(information: String){
        self.file = ""
        super.init()
    }
    

    
    
    func writeFiles(){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let fileURL = dir.appendingPathComponent(file)
            print(fileURL)
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {/* error handling here */}
    }


    }
}
*/
