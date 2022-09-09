//
//  NearbyServiceDelegate.swift
//  Bachelorarbeit
//
//  Created by JT X on 10.12.20.
//

import Foundation
import MultipeerConnectivity

protocol SuchenDelegate {
    func connectingState(state:MCSessionState)

    func didReceive(msg:String)
    
    func didReceiveFile(url: URL)
}
