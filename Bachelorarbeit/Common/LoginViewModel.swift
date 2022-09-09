//
//  LoginViewModel.swift
//  Bachelorarbeit
//
//  Created by JT X on 10.08.22.
//

import Foundation

import Foundation

class LoginViewModel: ObservableObject {
    
    var webService = Webservice()
    var username: String = "GroupRecorder"
    var password: String = "78zsd78fsd87fg8sdf9na09df"
    var type: String = "local"
    let loginUrl = "http://localhost:8080/auth/login"
 
    @Published var isAuthenticated: Bool = false
   
    func login(){
        let defaults = UserDefaults.standard
        
        Webservice().login(type: type, username: username, password: password) {
            result in
            switch result {
          //  case .success(let JWT):
          //      print(JWT)
            case .success(let accessToken):
                print(accessToken)
                defaults.setValue(accessToken, forKey:"jsonwebtoken")
                DispatchQueue.main.async{
                    self.isAuthenticated = true
                }
            case .failure(let error):
                //print(error.localizedDescription)
                print("")
            }
        }
    }
}


