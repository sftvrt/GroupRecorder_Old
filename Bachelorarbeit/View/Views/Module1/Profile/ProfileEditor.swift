//
//  ProfileEditor.swift
//  Bachelorarbeit
//
//  Created by JT X on 18.10.20.
//

import SwiftUI

struct ProfileEditor: View {
    @Binding var profile: Profile
    
    var body: some View {
        List {
            HStack {
                Text("Username").bold()
                Divider()
                TextField("Username", text: $profile.username)
            }
            
            HStack {
                Text("Alter").bold()
                Divider()
                TextField("Ihr Alter", text: $profile.Alter)
            }
            
            HStack {
                Text("Regionale Herkunft").bold()
                Divider()
                TextField("Ihre Herkunft", text: $profile.regionaleHerkunft)
            }
            
            
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Geschlecht").bold()
                
                Picker("Geschlecht", selection: $profile.Geschlecht) {
                    ForEach(Profile.Geschlecht.allCases, id: \.self) { season in
                        Text(season.rawValue).tag(season)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.top)
            
         
        
        }
    }
}

struct ProfileEditor_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditor(profile: .constant(.default))
    }
}
