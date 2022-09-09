//
//  changeLanguages.swift
//  Bachelorarbeit
//
//  Created by JT X on 14.07.22.
//

import Foundation
import UIKit


//: Constant
let systemLanguage = Locale.current.languageCode

//: Enumerations
enum lang : String, CaseIterable, Identifiable{
    case en, zh, de
    var id: Self {self}
}

//: Class
class LanguageSettings: NSObject, ObservableObject {
    @Published var lang : lang
    
    override init(){
        if systemLanguage == "de"{
            self.lang = .de
        } else if systemLanguage == "zh" {
            self.lang = .zh
        } else{
            self.lang = .en
        }
    }
}

extension String {
      func localizedStr(language:String) -> String {
          let path = Bundle.main.path(forResource: language, ofType: "lproj")
          let bundleName = Bundle(path: path!)
          return NSLocalizedString(self, tableName: nil, bundle: bundleName!, value: "", comment: "")
    }
}
    
    
    
    
    
    
    
    
    
    
