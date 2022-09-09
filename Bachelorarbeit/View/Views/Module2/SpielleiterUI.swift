//
//  SpielleiterUI.swift
//  Bachelorarbeit
//
//  Created by JT X on 01.11.20.
//



import Combine
import SwiftUI


struct SpielleiterUI: View {
    
    @EnvironmentObject var rootVM: RootViewModel
    @EnvironmentObject var nearbyService: NearbyService
    @EnvironmentObject var selectedLanguage : LanguageSettings
    @EnvironmentObject var selectedLang : LanguageSettings
    
    
    static let goalFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View{
        
        VStack{
            Text("\(self.nearbyService.sitzung.datum,formatter:Self.goalFormatter)")
                .padding(.top,10)
                .padding(.bottom,10)
            // Button: Suchen
            Button{
                nearbyService.showBrowsesrController()
            } label: {
                VStack{
                    HStack{
                        Image(systemName: "magnifyingglass").foregroundColor(.yellow).font(.system(size:64))
                    }
                    
                    HStack{
                        VStack{
                            Text((texts[33].localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue))).font(.system(size: 32, weight: .bold))
                                .frame(maxWidth:.infinity, alignment: .leading)
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color(#colorLiteral(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.27)).opacity(0.8))
                }
                .frame(maxWidth: 200,   maxHeight: 180)
                .background(Color(#colorLiteral(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            
            
            //Sitzungstitel
            List{
                Section(header:Text((texts[13].localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))){
                    TextField((texts[13].localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)), text: $nearbyService.sitzung.title).textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            NavigationLink(destination:AufnahmeUI()
                            .environmentObject(nearbyService)
                            .environmentObject(AudioRecorder(nearbyService))
                            .environmentObject(rootVM)
                           
            ){
                Text("Speichern")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(maxWidth: 320, maxHeight: 40)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(15)
            }
        }.onAppear{
            nearbyService.startBrowser()
        }
    }
    
}
