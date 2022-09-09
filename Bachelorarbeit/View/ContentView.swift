//
//  ContentView.swift
//  Bachelorarbeit
//
//  Created by JT X on 12.10.20.
//

import SwiftUI

enum ActiveSheet {
    case first, second
}

struct ContentView: View {
    @ObservedObject var rootVM = RootViewModel()
    
    @EnvironmentObject var userData: UserData
    
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var nearbyService: NearbyService
    
    init(texts:[String]) {
        UITableView.appearance().backgroundColor = .white
        
        // 统一底部标签栏样式
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().backgroundColor = .white
        
        // 统一导航栏样式
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = UIColor.white

    }
    
    // 作为属性可以避免每次切换都重新初始化三个界面的结构以及数据
    let profileHost = ProfileHost()
    let meeting = Meeting()
    let filesCenter = showFiles()
    
    var body: some View {
        let selection = Binding<Int>(
            get: { rootVM.tabSelection },
            set: { rootVM.tabSelection = $0
                print("Pressed tab: \($0)")
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshNavigationBar, object: rootVM.tabSelection)
                    }
                }
            })
//        let service = NearbyService(displayName: userData.profile.username,userData)
        ZStack {
            NavigationView {
                TabView(selection: selection) {
                    profileHost
                        .tabItem{
                            Image(systemName: "person")
                        }
                        .tag(0)
                    meeting
                        .tabItem{
                            Image(systemName: "folder")
                        }.tag(1)
                    filesCenter
                        .tabItem{
                            Image(systemName: "folder")
                        }.tag(2)
                }
                .accentColor(.blue)
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(rootVM.tabNavigationTitle,displayMode: .inline)
                .navigationBarHidden(rootVM.tabNavigationHidden)
                .navigationBarItems(leading:rootVM.tabNavigationBarLeadingItems,trailing: rootVM.tabNavigationBarTrailingItems)
                .environmentObject(audioRecorder)
                .environmentObject(nearbyService)
                .environmentObject(self.userData)
                .environmentObject(rootVM)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( texts:texts)
            .environmentObject(UserData())
            .environmentObject(LanguageSettings())
    }
}




