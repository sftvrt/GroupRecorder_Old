//
//  showConnection.swift
//  Bachelorarbeit
//
//  Created by JT X on 10.08.22.
//

import SwiftUI


//nearbyService.peerID.displayName

struct showConnection: View {
    @EnvironmentObject var nearbyService: NearbyService
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct showConnection_Previews: PreviewProvider {
    static var previews: some View {
        showConnection()
    }
}
