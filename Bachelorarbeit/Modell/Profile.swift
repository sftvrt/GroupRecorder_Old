//
//  Profile.swift
//  Bachelorarbeit
//
//  Created by JT X on 18.10.20.
//
import Foundation

struct Profile:Codable {
    
    var username: String
    var Alter : String
    var regionaleHerkunft : String
    var Geschlecht: Geschlecht
    var userLatitude: String
    var userLongitude: String
    var userCity: String
    var userCountry: String
    var timeInfo: [String:String]

    static let randomUserName = "Benutzername\((0...1000).randomElement()!)"
    static let `default` = Self(username: randomUserName, Geschlecht: .weiblich, Alter: "Ihr Alter", regionaleHerkunft: "Ihre Herkunft",timeInfo: [:])
    
    init(username: String, Geschlecht: Geschlecht = .weiblich, Alter: String, regionaleHerkunft: String,userLatitude: String = "",userLongitude: String = "",userCity: String = "",userCountry: String = "",timeInfo:[String:String] = [:]) {
        self.username = username
        self.Geschlecht = Geschlecht
        self.Alter = Alter
        self.regionaleHerkunft = regionaleHerkunft
        self.userLatitude = userLatitude
        self.userLongitude = userLongitude
        self.userCity = userCity
        self.userCountry = userCountry
        self.timeInfo = timeInfo
    }
    enum Geschlecht: String, CaseIterable,Codable {
        case weiblich = "weiblich"
        case männlich = "männlich"
    }
}
