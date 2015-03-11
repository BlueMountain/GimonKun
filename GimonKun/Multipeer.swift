//
//  Multipeer.swift
//  NewGimonKun
//
//  Created by Takuro Mori on 2014/12/11.
//  Copyright (c) 2014 Takuro Mori. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class Multipeer : UIViewController, MCSessionDelegate ,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate{
    
    var myPeerID : MCPeerID!
    var mySession : MCSession!
    var myBrowser : MCNearbyServiceBrowser!
    var myAdvertiser : MCNearbyServiceAdvertiser!
    let serviceType = "gimon1000r"

    override func viewDidLoad(){
        super.viewDidLoad()
    
        self.myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name);
        self.mySession = MCSession(peer: myPeerID);
        self.myBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType);
        self.myAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType);
        self.mySession.delegate = self;
        self.myAdvertiser.delegate = self;
        self.myBrowser.delegate = self;

    }
    
    /******
    Multipeer Conectivity
    ******/
    
    // --------------------
    // MCNearbyServiceBrowserDelegate
    // --------------------
    
    // error
    
    // browser:didNotStartBrowsingForPeers:
    func browser(browser: MCNearbyServiceBrowser!,
        didNotStartBrowsingForPeers error: NSError!){
            NSLog("browserError");
    }
    
    // browser:foundPeer:withDiscoveryInfo:
    func browser(browser: MCNearbyServiceBrowser!,
        foundPeer peerID: MCPeerID!,
        withDiscoveryInfo info: [NSObject : AnyObject]!){
            println("find peer:\(peerID.displayName)")
    }
    
    // browser:lostPeer:
    func browser(browser: MCNearbyServiceBrowser!,
        lostPeer peerID: MCPeerID!){
            println("Lost peer:\(peerID.displayName)")
    }
    
    // --------------------
    // MCNearbyServiceAdvertiserDelegate
    // --------------------
    
    // error
    // advertiser:didNotStartAdvertisingPeer:
    func advertiser(advertiser: MCNearbyServiceAdvertiser!,
        didNotStartAdvertisingPeer error: NSError!){
            NSLog("didNotStartAdvertisingPeer");
    }
    
    // Invitation Handling Delegate Methods
    // advertiser:didReceiveInvitationFromPeer:withContext:invitationHandler:
    func advertiser(advertiser: MCNearbyServiceAdvertiser!,
        didReceiveInvitationFromPeer peerID: MCPeerID!,
        withContext context: NSData!,
        invitationHandler: ((Bool,
        MCSession!) -> Void)!){
            println("(Input)invited");
    }
    
    // --------------------
    // MCSessionDelegate
    // --------------------
    
    // MCSession Delegate Methods
    
    // session:didReceiveData:fromPeer:
    func session(session: MCSession!,
        didReceiveData data: NSData!,
        fromPeer peerID: MCPeerID!){
            println("(Input)receive Data from\(peerID.displayName)");
    }
    
    
    // session:peer:didChangeState:
    func session(session: MCSession!,
        peer peerID: MCPeerID!,
        didChangeState state: MCSessionState){
            println("(Input)Change State:\(peerID)");
            
            if(state == MCSessionState.Connected){
                println("Move Conected State");
                dispatch_async(dispatch_get_main_queue()){
                }
            }
            if(state == MCSessionState.Connecting){
                println("Move Conecting State");
            }
            if(state == MCSessionState.NotConnected){
                println("Move Conect Loss State");
            }
            println("(Input)Peer in Session:\(session.connectedPeers)");
    }
    
    // session:didReceiveCertificate:fromPeer:certificateHandler:
    func session(session: MCSession!,
        didReceiveCertificate certificate: [AnyObject]!,
        fromPeer peerID: MCPeerID!,
        certificateHandler: ((Bool) -> Void)!){
            certificateHandler(true);
            println("Establish Conect");
    }
    
    /*xxxxx
    Not Use
    xxxxx*/
    // session:didStartReceivingResourceWithName:fromPeer:withProgress:
    // Called when a remote peer begins sending a file-like resource to the local peer. (required)
    func session(session: MCSession!,
        didStartReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!,
        withProgress progress: NSProgress!){
            NSLog("Start file-like data");
    }
    
    
    // session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:
    // Called when a remote peer sends a file-like resource to the local peer. (required)
    func session(session: MCSession!,
        didFinishReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!,
        atURL localURL: NSURL!,
        withError error: NSError!){
            NSLog("finish file-like data");
    }
    
    // session:didReceiveStream:withName:fromPeer:
    // Called when a remote peer opens a byte stream connection to the local peer. (required)
    func session(session: MCSession!,
        didReceiveStream stream: NSInputStream!,
        withName streamName: String!,
        fromPeer peerID: MCPeerID!){
            NSLog("receive bytestream");
    }

}
