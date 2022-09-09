//
//  Meeting.swift
//  Bachelorarbeit
//
//  Created by 刘小坤 on 2022/8/18.
//

import SwiftUI

struct Meeting: View {
    @EnvironmentObject var rootVM: RootViewModel
    
    @EnvironmentObject var userData: UserData
    
    @EnvironmentObject var service: NearbyService
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @EnvironmentObject var selectedLanguage : LanguageSettings
    @EnvironmentObject var selectedLang : LanguageSettings
    
    @StateObject var loginVM = LoginViewModel()
    
    @State private var isShowPresented: Bool = false
    @State private var activeSheet: ActiveSheet = .first
    
    var profileButton: some View {
        Button(action: {
            rootVM.tabSelection = 0
            NotificationCenter.default.post(name: .refreshNavigationBar, object: 0)
        }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    var settingButton : some View{
        Button(action: {
            isShowPresented = true
            self.activeSheet = .second
            rootVM.tabSelection = 1
        }) {
            Text(texts[34].localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue))
        } //: BUTTON
        
    }
    
    /// 参与者
    func setupParticipant() -> some View {
        return NavigationLink(destination:AufnahmeUI()
                                .environmentObject(AudioRecorder(service))
                                .environmentObject(service)
                                .environmentObject(rootVM),
                              isActive: $rootVM.isPop
        ){
            VStack{
                HStack{
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.purple)
                        .font(.system(size:64))
                        .padding(.top,10)
                }
                Spacer()
                HStack{
                    VStack{
                        // Ich bin
                        let IchBin = texts[30]
                        Text((IchBin.localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))
                            .font(.system(size: 14, weight: .medium))
                            .padding(.top,5)
                        //Mitspieler
                        let textMitspieler = texts[32]
                        Text((textMitspieler.localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))
                            .font(.system(size: 32, weight: .bold))
                            .padding(.bottom,5)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(#colorLiteral(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.27)).opacity(0.8))
                .padding(15)
                
            }
            .frame(maxHeight: 180)
            .background(Color(#colorLiteral(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.gray.opacity(0.8), radius: 20, x: 0, y: 10)
            .padding(20)
        }
    }
    
    /// 发起控制者
    func initiator() -> some View {
        return NavigationLink(destination:SpielleiterUI()
                                .environmentObject(service)
                                .environmentObject(rootVM)
        ){
            VStack {
                HStack {
                    Image(systemName: "person.fill").foregroundColor(.yellow)
                        .font(.system(size:64))
                        .padding(.top,10)
                }
                HStack {
                    VStack {
                        // Ich bin
                        let IchBin = texts[30]
                        Text((IchBin.localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))
                            .font(.system(size: 14, weight: .medium))
                            .padding(.top,5)
                        
                        // Spielleiter
                        let textSpielleiter = texts[31]
                        Text((textSpielleiter.localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))
                            .font(.system(size: 32, weight: .bold))
                            .padding(.bottom,5)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(#colorLiteral(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.27)).opacity(0.8))
                .padding(15)
                
            }
            .frame(maxHeight: 180)
            .background(Color(#colorLiteral(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.gray.opacity(0.8), radius: 20, x: 0, y: 10)
            .padding(20)
        }
    }
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: 10)
            setupParticipant()
            Spacer().frame(height: 10)
            initiator()
            Spacer().frame(height: 10)
            Button(action: {
                loginVM.login()
            }){
                HStack {
                    Spacer()
                    Text("Login")
                    Spacer()
                }
            }
            .frame(height: 44)
            .background(Color.blue)
            .foregroundColor(.white)
            .padding(20)
        }
        .background(Color.white)
        .onAppear {
            service.stopBrowser()
            service.stopAdvertising()
            service.connectHistoryNames = []
            audioRecorder.nearbyService.connectHistoryNames = []
        }
        .onDisappear {
            service.connectHistoryNames = []
            audioRecorder.nearbyService.connectHistoryNames = []
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshNavigationBar)) { (notif) in
            let index:Int = notif.object as! Int
            // 刷新导航栏
            if index == 1 {
                self.rootVM.tabNavigationHidden = false
                self.rootVM.tabNavigationTitle = ""
                self.rootVM.tabNavigationBarLeadingItems = .init(self.profileButton)
                self.rootVM.tabNavigationBarTrailingItems = .init(settingButton)
            }
        }
        .sheet(isPresented:self.$isShowPresented){
            if self.activeSheet == .first {
            }else {
                SettingView().environmentObject(selectedLanguage)
            }
        }
    }
}
