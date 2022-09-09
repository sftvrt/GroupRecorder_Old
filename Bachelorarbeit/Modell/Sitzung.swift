//
//  Aufnahmesitzung.swift
//  Bachelorarbeit
//
//  Created by JT X on 25.10.20.
//

import Foundation

struct Sitzung {
    
    var datum = Date()
    var title : String
    
    init(title:String) {
        self.datum = Date()
        self.title = title

    }
   
}
