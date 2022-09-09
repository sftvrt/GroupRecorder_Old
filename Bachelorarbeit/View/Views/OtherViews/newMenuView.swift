//
//  newMenuView.swift
//  Bachelorarbeit
//
//  Created by JT X on 27.07.22.
//

import SwiftUI

struct newMenuView: View {
    var body: some View {
        
        VStack{
            Text("GroupRecorder").font(.largeTitle).bold()
                .frame(maxWidth: .infinity,  alignment: .leading)
            Spacer()
        }
        VStack {
            //Ich bin
            Text("Ich bin").font(.system(size: 14, weight: .medium))
            //Spielleiter
            Text("Spielleiter").font(.system(size: 32, weight: .bold))
        }
    }
}

struct newMenuView_Previews: PreviewProvider {
    static var previews: some View {
        newMenuView()
    }
}
