//
//  WebService.swift
//  Bachelorarbeit
//
//  Created by JT X on 10.08.22.
//

import Foundation
import Alamofire


enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage:String)
}

struct LoginRequestBody: Codable {
    let type: String
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String?
    let account: String?
    let generalRole: String?
    let username: String?
    let email : String?
    let loginmethod: String?
    let active : String?
    let gender : String?
    let first_name : String?
    let last_name : String?
    let organization : String?
    let birthday : String?
    let address : String?
    let address_details : String?
    let town : String?
    let postcode : String?
    let state : String?
    let country : String?
    let language : String?
    let timezone : String?
    let phone : String?
    let projectRoles : String?
}

enum NetworkError:Error{
    case invalidURL
    case noData
    case decodingError
    case custom(errorMessage:String)
}

class Webservice  {
    // testAudio
    func getTestAudioUrl()-> URL {
        guard let filePathFive = Bundle.main .path(forResource: "testAudio", ofType: "wav") else { return URL.init(fileURLWithPath: "") }
        return URL.init(fileURLWithPath: filePathFive)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
          //Trust the certificate even if not valid
          let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
          completionHandler(.useCredential, urlCredential)
       }
    
    // alamofire上传方法
    func uploadAudios(token:String, audioURL:URL) {
        
        //audiodata
        let audioData = try! Data(contentsOf: audioURL)
        
        // uoloadurl
        // https://clarin.phonetik.uni-muenchen.de/webapps/octra-api-dev/v1/projects/{project_id}/tasks
        let urlstring = "http://localhost:8080/projects/1/tasks"
  //  "https://clarin.phonetik.uni-muenchen.de/webapps/octra-api-dev/v1/projects/1/tasks"
        
        guard let urlString = urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else {
            print("url problem1")
            return
        }
        
        guard let uploadurl = URL (string: urlString) else {
            print("url problem2")
            return
        }
        
        let headers: HTTPHeaders = [
            "contentType": "multipart/form-data",
            "X-App-Token": "7z87mhgdf89n7dgfn8s7ßa9sdufm8",
            "authorization": "Bearer " + token
        ]
        
        let parameters: [String:Any] = [
            "inputs": [audioData],
            "properties": [
                "type": "annotation"
     /*           "admin_comment" : "",
                "assessment" : "",
                "code": "",
                "comment": "",
                "enddate": "",
                "files_destination":"",
                "log": [],
                "media": "",
                "nexttask_id" : "",
                "orgtext" : "",
                "pid": "",
                "priority" : "",
                "startdate" : "",
                "status" : "",
                "tool_id" : "",
                "worker_id" : ""
                */
            ]
            
        ]
        
        
        AF.upload(multipartFormData: { multiPart in
                for (key, value) in parameters {
                    if let temp = value as? String {
                        multiPart.append(temp.data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? Int {
                        multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? NSArray {
                        temp.forEach({ element in
                         //   let keyObj = key + "[]"
                            let keyObj = key
                            if let string = element as? String {
                                multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                            } else if let num = element as? Int {
                                    let value = "\(num)"
                                multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                            } else if let datafile = element as? Data {
                                multiPart.append(datafile, withName: keyObj,fileName: "testAudio.wav", mimeType: "audio/wave")
                            } else  {
                                print(element)
                                print(type(of: element))
                            }
                        })
                    
                    }
                    if let children = value as? Dictionary<String, Any> {
                           let to_append = children.description.jSONStringToData()
                           
                           let dicdata = try? JSONSerialization.data(withJSONObject: children, options: [])
                           let str = String(data: dicdata!, encoding: String.Encoding.utf8)
                           
                           multiPart.append(str!.data(using: .utf8)!, withName: key)
                       }
                }
      //      multiPart.append(audioData, withName: "testFile", fileName: "testFile.wav", mimeType: "audio/wav")
            }, to:  "http://localhost:8080/projects/1/tasks", headers: headers)
                .uploadProgress(queue: .main, closure: { progress in
                    //Current upload progress of file
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .responseJSON(completionHandler: { data in
                    //Do what ever you want to do with response
                    print(data)
                })
    }

   
    func login(type: String,username: String, password: String, completion: @escaping(Result<String, AuthenticationError>) -> Void){
        

     /*
        guard let url = URL(string: "http://localhost:8080/auth/login ") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        */
        
    //    "https://clarin.phonetik.uni-muenchen.de/webapps/octra-api-dev/v1/auth/login"
        guard let webUrl = URL(string: "http://localhost:8080/auth/login") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = LoginRequestBody(type: type, username: username, password: password)
        
        var request = URLRequest(url:webUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("7z87mhgdf89n7dgfn8s7ßa9sdufm8", forHTTPHeaderField: "X-App-Token")
        request.httpBody = try? JSONEncoder().encode(body)
 
   
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
      //      guard let data = data else {
      //          return
      //      }
            
            print(String(data: try! JSONEncoder().encode(body), encoding: .utf8)!)
          
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "no data")))
                return
            }
            
            // data to String
            guard let need = String(data: data, encoding: .utf8) else {
                completion(.failure(.custom(errorMessage: "no need")))
                return
            }
            
            do{
            let jsonObject = try JSONSerialization.jsonObject(with: data)
    
                let dictionary = jsonObject as? [String: Any]
                for key in dictionary!.keys {
                   print("\(key)")
                }
                
                let accessToken = dictionary!["accessToken"]
                completion(.success(accessToken as! String))
             //   print(dictionary ?? "nonono")
            }
           catch{
                print("JSONSerialization error:", error)
          }
            
            if(error != nil) {
                print("Error: \(String(describing: error))")
            } else {
              // print(String(data: data, encoding: .utf8)! )
            //    print(JWTFile as Any)
                print(data)
            }
            
        }.resume()
    }
}
