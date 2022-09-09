//
//  ProfileHost.swift
//  Bachelorarbeit
//
//  Created by JT X on 18.10.20.
//

import SwiftUI

struct ProfileHost: View {
    @EnvironmentObject var rootVM: RootViewModel
    
    @Environment(\.editMode) var mode
    
    @EnvironmentObject var userData: UserData
    
    @State var draftProfile = Profile.default
    
    var cancelButton: some View {
        Button(self.mode?.wrappedValue == .active ? "Cancel" : "") {
            self.draftProfile = self.userData.profile
            self.mode?.animation().wrappedValue = .inactive
            self.rootVM.tabNavigationBarLeadingItems = .init(cancelButton)
            self.rootVM.tabNavigationBarTrailingItems = .init(editButton)

       }
    }
    
    var editButton : some View{
        Button(self.mode?.wrappedValue == .active ? "Done" : "Edit") {
            self.mode?.animation().wrappedValue = (self.mode?.wrappedValue == .active ?  .inactive : .active)
            self.rootVM.tabNavigationBarLeadingItems = .init(cancelButton)
            self.rootVM.tabNavigationBarTrailingItems = .init(editButton)
        }
    }
    
   func setupRootVM() {
       self.rootVM.tabNavigationHidden = false
       self.rootVM.tabNavigationTitle = ""
       self.rootVM.tabNavigationBarLeadingItems = .init(cancelButton)
       self.rootVM.tabNavigationBarTrailingItems = .init(editButton)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if self.mode?.wrappedValue == .inactive {
                ProfileSummary()
                    .environmentObject(userData)
            } else {
                ProfileEditor(profile: $draftProfile)
                    .onAppear {
                        self.draftProfile = self.userData.profile
                    }
                    .onDisappear {
                        self.userData.profile = self.draftProfile
                    }
            }
        }
        .onAppear {
            if rootVM.tabSelection == 0 {
                setupRootVM()
            }
        }.onReceive(NotificationCenter.default.publisher(for: .refreshNavigationBar)) { (notif) in
            let index:Int = notif.object as! Int
            // 刷新导航栏
            if index == 0 {
                setupRootVM()
            }
           
        }
    }
}
