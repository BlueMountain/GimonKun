//
//  Enter.swift
//  NewGimonKun
//
//  Created by Takuro Mori on 2014/11/26.
//  Copyright (c) 2014 Takuro Mori. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AdSupport

class Enter: Multipeer, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{

    //initialize
    //-----------------------------------------------------------------------------
    //general func
    
    var tableView : UITableView?
    var PlusButton = UIButton()
    var SubName = "";
    var SubNameList : [String] = []
    var roomMasterFlag : Int = 0

    
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    
    //-----------------------------------------------------------------------------
    //Plus Window
    let Plus_Window = UIWindow()
    var OKButton = UIButton()
    var CancelButton = UIButton()
    var ClassName = UITextField()
    
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------

    /******
    General view
    ******/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        
        width = self.view.frame.width
        height = self.view.frame.height
        
        tableView = UITableView(frame: CGRectMake(0, height/5.68, width, height/1.35))
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorColor = UIColor.clearColor()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView!)
        
        var SelectLabel = UILabel(frame: CGRectMake(width/5.3, height/13.5, width/1.62, height/18.9))
        SelectLabel.textColor = UIColor.whiteColor()
        SelectLabel.textAlignment = NSTextAlignment.Center
        SelectLabel.font = UIFont.boldSystemFontOfSize(30)
        SelectLabel.text = "Select Class"
        self.view.addSubview(SelectLabel)
        
        PlusButton.frame = CGRectMake(width/1.14, height/14.2, width/10.7, height/18.9)
        PlusButton.setImage(UIImage(named: "plus.png"), forState: .Normal)
        PlusButton.addTarget(self, action: "push_PlusButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(PlusButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Enter Send
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.Plus_Window.endEditing(true)
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        println("(Enter)ViewWillAppear");
        self.myAdvertiser.startAdvertisingPeer();
    }
    
    //-----------------------------------------------------------------------------
    
    /******
    Plus Winow
    ******/
    func push_PlusButton(sender : UIButton){
        Plus_Window.frame = CGRectMake(0, 0, width/1.07, height/1.89)
        Plus_Window.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        Plus_Window.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        Plus_Window.alpha = 0.9
        
        Plus_Window.makeKeyWindow()
        self.Plus_Window.makeKeyAndVisible()
        
        OKButton.frame = CGRectMake(0, 0, width/3.2, height/14.2)
        OKButton.backgroundColor = UIColor.orangeColor()
        OKButton.setTitle("OK", forState: .Normal)
        OKButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        OKButton.layer.cornerRadius = 20.0
        OKButton.layer.position = CGPointMake(self.Plus_Window.frame.width/4*3, self.Plus_Window.frame.height-35)
        OKButton.addTarget(self, action: "onClickButton:", forControlEvents: .TouchUpInside)
        
        self.Plus_Window.addSubview(OKButton)
        
        //cancel button
        CancelButton.frame = CGRectMake(0, 0, width/3.2, height/14.2)
        CancelButton.backgroundColor = UIColor.orangeColor()
        CancelButton.setTitle("Cancel", forState: .Normal)
        CancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        CancelButton.layer.cornerRadius = 20.0
        CancelButton.layer.position = CGPointMake(self.Plus_Window.frame.width/4, self.Plus_Window.frame.height-35)
        CancelButton.addTarget(self, action: "onClickButton:", forControlEvents: .TouchUpInside)
        
        self.Plus_Window.addSubview(CancelButton)
        
        ClassName = UITextField(frame: CGRectMake(0, 0, width/1.45, height/18.9))
        ClassName.layer.position = CGPointMake(width/2.13,height/3.79)
        ClassName.borderStyle = UITextBorderStyle.RoundedRect
        ClassName.delegate = self
        ClassName.placeholder = "Write Class Name"
        
        self.Plus_Window.addSubview(ClassName)
    }
    
    func onClickButton(sender: UIButton) {
        Plus_Window.hidden = true
        if sender == OKButton {
            self.SubName = ClassName.text
            roomMasterFlag = 1
            self.SubNameList.append(self.SubName)
            self.myAdvertiser.stopAdvertisingPeer()
            self.myBrowser.startBrowsingForPeers()
            self.performSegueWithIdentifier("toInput", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        myBrowser.stopBrowsingForPeers()
        if segue.identifier == "toInput"{
            var VC : Input = segue.destinationViewController as Input
            VC.SubName = self.SubName
            VC.roomMasterFlag = self.roomMasterFlag
        }
    }
    
    //-----------------------------------------------------------------------------
    
    /******
    tableView
    ******/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.SubName = SubNameList[indexPath.row]
        self.roomMasterFlag = 0
        self.myBrowser.startBrowsingForPeers()
        self.performSegueWithIdentifier("toInput", sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.SubNameList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "\(SubNameList[indexPath.row])";
        return cell
    }
    
    //-----------------------------------------------------------------------------
    
    /******
    Multipeer Conectivity
    ******/
    
    // browser:foundPeer:withDiscoveryInfo:
    override func browser(browser: MCNearbyServiceBrowser!,
        foundPeer peerID: MCPeerID!,
        withDiscoveryInfo info: [NSObject : AnyObject]!){
            println("(Enter)Find Peer:\(peerID.displayName)");
            let encodedMsg = self.SubName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            self.myBrowser.invitePeer(peerID, toSession: self.mySession, withContext: encodedMsg, timeout: 1)
            //browser.invitePeer(peerID, toSession: self.mySession, withContext: encodedMsg, timeout: 1)
    }
    


    // Invitation Handling Delegate Methods
    
    // advertiser:didReceiveInvitationFromPeer:withContext:invitationHandler:
    override func advertiser(advertiser: MCNearbyServiceAdvertiser!,
        didReceiveInvitationFromPeer peerID: MCPeerID!,
        withContext context: NSData!,
        invitationHandler: ((Bool,
        MCSession!) -> Void)!){
            
            var foundedSubjectName = NSString(data: context, encoding: NSUTF8StringEncoding)
            if(!Swift.contains(self.SubNameList, foundedSubjectName!)){
                self.SubNameList.append(foundedSubjectName!)
            }
            println("(Enter)Update Class List:\(self.SubNameList)")
            self.tableView?.reloadData()
            invitationHandler(false, self.mySession)
            println("(Enter)refuse invite")
    }
    
}