//
//  NearbyService.swift
//  Bachelorarbeit
//
//  Created by JT X on 10.12.20.
//



import Foundation
import MultipeerConnectivity
import Combine

class NearbyService: NSObject,ObservableObject{
    
    var nearbyServiceDelegate: SuchenDelegate?
    private var serviceType = "find"

    var invite: MCPeerID?
    var leader: MCPeerID?
    let peerID: MCPeerID
    var connectedNames: [String] = []
    var connectHistoryNames: Set<String> = []

    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    var session: MCSession?
    
    @Published var sitzung: Sitzung = Sitzung(title: "")
    
    var isBrowser = false
    var browserActive = false
    var advertisingActive = false
    var userData: UserData
    
    init(displayName: String,_ t_userData: UserData) {
        peerID = MCPeerID(displayName:displayName)
        userData = t_userData
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer:peerID,discoveryInfo:nil,serviceType:serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer:peerID,serviceType:serviceType)
        super.init()
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    

    
    func startBrowser() {
        guard !advertisingActive && !browserActive else {
            return
        }
        session = MCSession(
          peer: peerID,
          securityIdentity: nil,
          encryptionPreference: .none)
        session?.delegate = self

       nearbyServiceBrowser.startBrowsingForPeers()
        isBrowser = true
        browserActive = true
        
        print("create browser session")
    }
    
    func stopBrowser() {
        guard browserActive else {
            return
        }
        session?.disconnect()
        session = nil
        nearbyServiceBrowser.stopBrowsingForPeers()
        browserActive = false
        isBrowser = false
        print("stop browser session")
    }
    
    func startAdvertising() {
        guard !advertisingActive && !browserActive else {
            return
        }
        session = MCSession(
          peer: peerID,
          securityIdentity: nil,
          encryptionPreference: .none)
        session?.delegate = self
        
        nearbyServiceAdvertiser.startAdvertisingPeer()
        advertisingActive = true
        print("startAdvertisingPeer")
        
    }
    
    func stopAdvertising() {
        guard advertisingActive else {
            return
        }
        session?.disconnect()
        session = nil
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        advertisingActive = false

        print("stopAdvertisingPeer")
    }
    
    func showBrowsesrController() {
        guard
          let window = UIApplication.shared.windows.first,
          let session = session
        else { return }

        let mcBrowserViewController = MCBrowserViewController(serviceType: serviceType, session: session)
        mcBrowserViewController.delegate = self
        window.rootViewController?.present(mcBrowserViewController, animated: true)
        print("startBrowsingForPeers")
    }
    

    func send(msg: String) {
        guard let session = session else {
            return
        }
        
        if let data = msg.data(using: .utf8), session.connectedPeers.count > 0{
            try? session.send(data, toPeers:session.connectedPeers, with: .reliable)
            print("start sending Message")
        }
    }
    
    func sendFile(url: URL)  {
        print("start sending file: \(url)")
        guard let session = session, let leader = leader else {
            return
        }
    
        session.sendResource(at: url, withName: url.lastPathComponent, toPeer: leader) { (error) in
            if let error = error {
                print("send file error", error)
            } else {
                print("send file success")
            }
        }
    }
}


extension NearbyService: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        var connectedPeersDisplayNames: [String] = []
        
        for mCPeerID in session.connectedPeers {
            connectedPeersDisplayNames.append(mCPeerID.displayName);
        }
        self.connectedNames = connectedPeersDisplayNames
        self.connectHistoryNames.update(with: peerID.displayName)
        
        self.nearbyServiceDelegate?.connectingState(state: state)
        
        switch state{
        case .connecting:
            print("connecting \(peerID.displayName)")
        case .connected:
            print("connected:\(peerID.displayName)")
            if !isBrowser && invite == peerID {
                leader = peerID
                print("found leader")
                
            }
        case .notConnected:
            print("not connected:\(peerID.displayName)")
            if !isBrowser && invite == peerID {
                invite = nil
                leader = nil
                print("lose leader")
            }
        @unknown default:
            print("unknown state:\(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("did receive data:\(data)")
        if let msg = String(data:data, encoding: .utf8){
            DispatchQueue.main.async{ // manipulate the UI
                self.nearbyServiceDelegate?.didReceive(msg:msg)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let localURL = localURL, error == nil else {
            print("receive file error", error!)
            return
        }
        let fileManager = FileManager.default
       let newURL = DataStorageManager().getStorageRecordPathUrl(subPath: resourceName)
        do {
            try fileManager.moveItem(at: localURL, to: newURL)
            print("receive file", newURL)
        } catch let error {
            print("receive file error", error)
        }
        DispatchQueue.main.async {
            self.nearbyServiceDelegate?.didReceiveFile(url: newURL)
        }
    }
}

extension NearbyService:MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard
          let window = UIApplication.shared.windows.first
        else {
            return
        }

        let title = "Accept \(peerID.displayName)"
        let message = "Would you like to accept: \(peerID.displayName)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            invitationHandler(false, self.session)
        }))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.invite = peerID
          invitationHandler(true, self.session)
        })
        window.rootViewController?.present(alertController, animated: true)
        
    }
}

extension NearbyService: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        guard let session = session else {
//            return
//        }
//        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer:\(peerID.displayName)")
    }

}

extension NearbyService: MCBrowserViewControllerDelegate {
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    browserViewController.dismiss(animated: true) {
//      self.connectedToChat = true
    }
  }

  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    session?.disconnect()
    browserViewController.dismiss(animated: true)
  }
}




