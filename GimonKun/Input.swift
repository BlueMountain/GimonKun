//
//  Input.swift
//  NewGimonKun
//
//  Created by Takuro Mori on 2014/11/26.
//  Copyright (c) 2014 Takuro Mori. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity
import AdSupport

class Input: Multipeer,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate{
    
    //initialize
    //-----------------------------------------------------------------------------
    //general func
    var Super_State : Int = 0
    struct Question {
        var Message:String
        var Image:UIImage?
        var Countnum:Int
        var Buttonstate:Bool
        var Answer:[String]
        var Solved:Bool
        var ID:String
    }
    var SubName : String = ""
    var roomMasterFlag : Int = 0
    var Question_Array:[Question] = [Question]()
    var Question_Num : Int = 0
    var Back_Button = UIButton()
    
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    
    // ID for Vender.
    let myIDforVender = UIDevice.currentDevice().identifierForVendor
    
    // ID for Ad.
    let myASManager = ASIdentifierManager()
    var DisplayID:[Int] = [Int]()
    
    var BlockList = NSMutableArray()
   
    var Counter:Int = 0
    var RecieveNum:Int = 0
    var COUNTER2:Int = 0
    
    var BeforeData1 : NSData!
    var BeforeData2 : NSData!
    var BeforeData3 : NSData!
    var BlockFlag : Bool = false
    
    //-----------------------------------------------------------------------------
    //Input View (main)
    var subName_Label = UILabel()
    var Population = UILabel()
    var Save_Button = UIButton()
    var Input_Table = UITableView()
    var Camera_Button = UIButton()
    var Input_Text = UITextField()
    var send_Button = UIButton()
    var ArrayData : NSData!
    var InputTextBack = UIImageView()
    
    var str : String = ""

    var TextFieldOriginY:CGFloat = 0.0
    var SendButtonOriginY:CGFloat = 0.0
    var ImageOriginY:CGFloat = 0.0
    var TextFieldOriginY2:CGFloat = 0.0
    var SendButtonOriginY2:CGFloat = 0.0
    var ImageOriginY2:CGFloat = 0.0
    
    //-----------------------------------------------------------------------------
    //Save Window
    let Save_Window = UIWindow()
    var SaveLabel = UILabel()
    var OKButton = UIButton()
    var NoButton = UIButton()
    var CancelButton = UIButton()
    var FileData = NSMutableArray()
    
    //-----------------------------------------------------------------------------
    //Camera Window
    let Camera_Window = UIWindow()
    var Camera_Session : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myImage_Output : AVCaptureStillImageOutput!
    var myImage = UIImage()
    
    //-----------------------------------------------------------------------------
    //Illust Window
    let Illust_Window = UIView()
    var pre_Image : UIImage!
    var canvas_View : UIImageView!
    var touchedPoint : CGPoint = CGPointZero
    var bezierPath : UIBezierPath! = nil
    
    var red :CGFloat=1.0
    var green :CGFloat = 0.0
    var blue :CGFloat = 0.0
    var alpha :CGFloat = 1.0
    var Penwidth :CGFloat = 5.0
    
    var firstMovedFlag : Bool = true
    var image : UIImage! = nil
    var Image_array_undo : [UIImage] = [UIImage]()
    var Image_array_redo : [UIImage] = [UIImage]()
    
    //-----------------------------------------------------------------------------
    //Detail Window
    let Detail_Window = UIWindow()
    var Solved_Button = UIButton()
    var Answer_Table = UITableView()
    var Detail_Text = UITextField()
    var Answer_Button = UIButton()
    var DetailTextBack = UIImageView()
    var Question_Label = UILabel()
    var Question_Back = UIImageView()
    var Question_Image = UIImage()
    var Block_Button = UIButton()
    
    //-----------------------------------------------------------------------------
    //Expand Window
    let Expand_Window = UIWindow()
    //-----------------------------------------------------------------------------
    
    /******
    general func
    ******/
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        
        width = self.view.frame.width
        height = self.view.frame.height
        
        //tap notice    for  Closekeyboard
//        let _singleTap = UITapGestureRecognizer(target: self, action: "onTap:");
//        _singleTap.numberOfTapsRequired = 1;
//        view.addGestureRecognizer(_singleTap);
        
        
        //Input Window
        InputInit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        //MultiPeer
        var timer = NSTimer.scheduledTimerWithTimeInterval(8.0, target:self, selector: Selector("startBrowsingInEmptyRoom"),userInfo: nil, repeats: false)
        
        myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name+"INroom");
        
        self.myAdvertiser.startAdvertisingPeer();
        println("(Input)Begin Advertise")
        if(self.roomMasterFlag == 1){
            println("Be RoomMaster");
            self.myAdvertiser.stopAdvertisingPeer();
            self.myBrowser.startBrowsingForPeers();
        }
        BlockFile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
//    //Close keyboard if onTap
//    func onTap (recognizer:UIPanGestureRecognizer){
//        Input_Text.resignFirstResponder();
//    }
    
    
    
    //Return button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        Input_Text.resignFirstResponder();
        if Super_State == 0{
            if countElements(Input_Text.text) != 0 {
                Sent()
            }
        }else if Super_State == 4{
            ReloadView()
        }
        return true
    }
    
    //Character limit
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        str = textField.text + string

        if (countElements("\(str)")<35) && (countElements("\(str)")>0){
            return true
        }
        else{
            let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "Over 35 Character"
                alert.addButtonWithTitle("OK")
                alert.show()
                return false
            }
        }
    


    //keyboard
    //Replace these functions
    func keyboardWillShow(sender: NSNotification) {
        if Super_State == 0{
            let dict:NSDictionary = sender.userInfo!
            let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
            let rect : CGRect = s.CGRectValue()
            var frame = self.Input_Text.frame
            TextFieldOriginY2 = TextFieldOriginY
            TextFieldOriginY = frame.origin.y
            var offset = (rect.height - ((self.view.frame.height - self.Input_Text.frame.origin.y) + self.Input_Text.frame.size.height))+(height/8.11)
            frame.origin.y = offset>0 ? frame.origin.y - offset : frame.origin.y
            self.Input_Text.frame = frame
            
            frame = self.send_Button.frame
            SendButtonOriginY2 = SendButtonOriginY
            SendButtonOriginY = frame.origin.y
            offset = (rect.height - ((self.view.frame.height - self.send_Button.frame.origin.y) + self.send_Button.frame.size.height))+(height/8.11)
            frame.origin.y = offset>0 ? frame.origin.y - offset : frame.origin.y
            self.send_Button.frame = frame
            
            frame = self.InputTextBack.frame
            ImageOriginY2 = ImageOriginY
            ImageOriginY = frame.origin.y
            offset = (rect.height - ((self.view.frame.height - self.InputTextBack.frame.origin.y) + self.InputTextBack.frame.size.height))+(height/5.68)
            frame.origin.y = offset>0 ? frame.origin.y - offset : frame.origin.y
            self.InputTextBack.frame = frame
        }
        else if Super_State == 4 {
            let dict:NSDictionary = sender.userInfo!
            let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
            let rect : CGRect = s.CGRectValue()
            var frame = self.Detail_Text.frame
            TextFieldOriginY2 = TextFieldOriginY
            TextFieldOriginY = frame.origin.y
            var offset = (rect.height - ((self.view.frame.height - self.Detail_Text.frame.origin.y) + self.Detail_Text.frame.size.height))+(height/8.11)
            frame.origin.y = offset>0 ? frame.origin.y - offset : frame.origin.y
            self.Detail_Text.frame = frame
            
            frame = self.Answer_Button.frame
            SendButtonOriginY2 = SendButtonOriginY
            SendButtonOriginY = frame.origin.y
            offset = (rect.height - ((self.view.frame.height - self.Answer_Button.frame.origin.y) + self.Answer_Button.frame.size.height))+(height/8.11)
            frame.origin.y = offset>0 ? frame.origin.y - offset : frame.origin.y
            self.Answer_Button.frame = frame
            
            frame = self.DetailTextBack.frame
            ImageOriginY2 = ImageOriginY
            ImageOriginY = frame.origin.y
            offset = (rect.height - ((self.view.frame.height - self.DetailTextBack.frame.origin.y) + self.DetailTextBack.frame.size.height))+(height/5.68)
            frame.origin.y = offset>0 ? frame.origin.y - offset : frame.origin.y
            self.DetailTextBack.frame = frame
        }
    }
    func keyboardWillHide(sender: NSNotification) {
        if Super_State == 0{
            let dict:NSDictionary = sender.userInfo!
            let s:NSValue = dict.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
            let rect : CGRect = s.CGRectValue()
            
            var frame = self.Input_Text.frame
            if TextFieldOriginY2 == 0.0{
                frame.origin.y = TextFieldOriginY
            }else{
                frame.origin.y = TextFieldOriginY2
            }
            self.Input_Text.frame = frame
            
            frame = self.send_Button.frame
            if SendButtonOriginY2 == 0.0{
                frame.origin.y = SendButtonOriginY
            }else{
                frame.origin.y = SendButtonOriginY2
            }
            self.send_Button.frame = frame
            
            frame = self.InputTextBack.frame
            if ImageOriginY2 == 0.0{
                frame.origin.y = ImageOriginY
            }else{
                frame.origin.y = ImageOriginY2
            }
            self.InputTextBack.frame = frame
            
            TextFieldOriginY = 0.0
            SendButtonOriginY = 0.0
            ImageOriginY = 0.0
            TextFieldOriginY2 = 0.0
            SendButtonOriginY2 = 0.0
            ImageOriginY2 = 0.0
        }else if Super_State == 4{
            let dict:NSDictionary = sender.userInfo!
            let s:NSValue = dict.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
            let rect : CGRect = s.CGRectValue()
            
            var frame = self.Detail_Text.frame
            if TextFieldOriginY2 == 0.0{
                frame.origin.y = TextFieldOriginY
            }else{
                frame.origin.y = TextFieldOriginY2
            }
            self.Detail_Text.frame = frame
            
            frame = self.Answer_Button.frame
            if SendButtonOriginY2 == 0.0{
                frame.origin.y = SendButtonOriginY
            }else{
                frame.origin.y = SendButtonOriginY2
            }
            self.Answer_Button.frame = frame
            
            frame = self.DetailTextBack.frame
            if ImageOriginY2 == 0.0{
                frame.origin.y = ImageOriginY
            }else{
                frame.origin.y = ImageOriginY2
            }
            self.DetailTextBack.frame = frame
            
            TextFieldOriginY = 0.0
            SendButtonOriginY = 0.0
            ImageOriginY = 0.0
            TextFieldOriginY2 = 0.0
            SendButtonOriginY2 = 0.0
            ImageOriginY2 = 0.0
        }
    }
    
    func push_BackButton(sender:UIButton){
        if Super_State == 0{
            CheckSave()
        }else if Super_State == 4{
            Super_State = 0
            self.Detail_Window.endEditing(true)
            Solved_Button.removeFromSuperview()
            Detail_Window.hidden = true
            Back_Button.frame = CGRectMake(10, 37, 20, 35)
            self.view.addSubview(Back_Button)
        }else if Super_State == 5{
            details()
            self.Expand_Window.hidden = true
        }
    }
    
    //class disappear
     override func viewWillDisappear(animated: Bool) {
        self.myBrowser.stopBrowsingForPeers();
        self.myAdvertiser.stopAdvertisingPeer();
        self.mySession.disconnect();
    }
    
    //-----------------------------------------------------------------------------
    
    /******
    Input View (main)(SuperState == 0)
    ******/

    //Input init
    func InputInit(){
        subName_Label.frame = CGRectMake(width/9, height/16, width/1.28, height/14.2)
        subName_Label.textAlignment = NSTextAlignment.Center
        subName_Label.font = UIFont.boldSystemFontOfSize(20)
        subName_Label.textColor = UIColor.whiteColor()
        subName_Label.text = SubName
        self.view.addSubview(subName_Label)
        
        Population.frame = CGRectMake(width/2, height/8.74, width/6.4, height/14.2)
        Population.textAlignment = NSTextAlignment.Center
        Population.font = UIFont.systemFontOfSize(17.0)
        Population.textColor = UIColor.whiteColor()
        self.view.addSubview(Population)
        
        Input_Table.frame = CGRectMake(0, height/5.68, width, height/1.35)
        Input_Table.delegate = self
        Input_Table.dataSource = self
        Input_Table.separatorColor = UIColor.clearColor()
        var nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        Input_Table.registerNib(nib, forCellReuseIdentifier: "InputCell")
        Input_Table.tag = 1
        self.view.addSubview(Input_Table)
        
        InputTextBack.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        InputTextBack.frame = CGRectMake(0, height/1.1, width, height/11.36)
        self.view.addSubview(InputTextBack)

        Camera_Button.frame = CGRectMake(width/36, height/1.084, width/8.9, height/18.9)
        Camera_Button.setImage(UIImage(named: "camera.png"), forState: .Normal)
        Camera_Button.addTarget(self, action: "Camera:", forControlEvents: .TouchUpInside)
        self.view.addSubview(Camera_Button)
        
        Input_Text.frame = CGRectMake(width/6.7, height/1.08, width/1.58, height/18.9)
        Input_Text.delegate = self
        Input_Text.borderStyle = UITextBorderStyle.RoundedRect
        Input_Text.placeholder = "Write Your Question!"
        self.view.addSubview(Input_Text)
        
        send_Button.frame = CGRectMake(width/1.26, height/1.08, width/5.3, height/18.9)
        send_Button.setImage(UIImage(named: "send.png"), forState: .Normal)
        send_Button.addTarget(self, action: "SentButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(send_Button)
        
        Back_Button.frame = CGRectMake(width/32, height/15.33, width/16, 35)
        Back_Button.setImage(UIImage(named: "back.png"), forState: .Normal)
        Back_Button.addTarget(self, action: "push_BackButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(Back_Button)
        
        ArrayData = NSKeyedArchiver.archivedDataWithRootObject([])

        
        var Fnum = Int(arc4random() % 8)
        DisplayID.append(Fnum)
        for i in 0..<3{
            var Plusnum = 0
            if i==0{
                Plusnum = 9
            }else if i==1{
                Plusnum = 14
            }else if i==2{
                Plusnum = 19
            }
            var Fnum = Int(arc4random() % 4) + Plusnum
            DisplayID.append(Fnum)
        }
        Fnum = Int(arc4random() % 12) + 24
        DisplayID.append(Fnum)
    }
    
    //button init
    func ButtonInit(Button btn:UIButton, Order TAG:Int, State state:Bool){
        btn.setImage(UIImage(named: "me_too_before1.png"), forState: .Normal)
        btn.setImage(UIImage(named: "me_too_after.png"), forState: .Disabled)
        btn.addTarget(self, action: "Metoo:", forControlEvents: .TouchUpInside)
        btn.tag = TAG+2
        if state{
            btn.enabled = false
        }
        else{
            btn.enabled = true
        }
    }
    
    //Block List init
    func BlockFile(){
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("Block.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("Don't make file")
                return
            }
        }
        
        var FileData = NSArray(contentsOfFile: filePath)
        if FileData != nil{
            for data in FileData!{
                var BlockData = String(data as NSString)
                BlockList.addObject(BlockData)
            }
        }

    }
    
    //Send button was pushed
    func SentButton(sender:UIButton){
        if countElements(Input_Text.text) != 0 {
            Sent()
        }
    }
    
    func Sent(){
        
        let myIDforAd = myASManager.advertisingIdentifier

        var NewQuestion = Question(Message: Input_Text.text, Image:nil, Countnum: 0, Buttonstate: false, Answer: [], Solved: false, ID:myIDforAd.UUIDString)
        Question_Array.append(NewQuestion)
        Input_Table.reloadData()
        
        var tmp = NewQuestion.Message as NSString
        tmp = tmp + "<$#$>" + myIDforAd.UUIDString + "<$#$>" + "0"
        
        //var tmpData = NSData(bytesNoCopy: &NewQuestion, length: sizeof(Question))
        //var Send_Data = NSData(bytes: &NewQuestion, length: sizeof(Question))
        
        
        var Send_Data = tmp.dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        Send_Data = "ArrayEmpty".dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        Send_Data = "Empty".dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        
        var indexPath = NSIndexPath(forItem: Question_Array.count-1, inSection: 0)
        Input_Table.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        
        self.view.endEditing(true)
        Input_Text.text = ""
        Input_Text.placeholder = "Write Question!"
        
    }

    //Metoo push
    func Metoo(sender : UIButton){
        sender.tag = sender.tag-2
        Question_Array[sender.tag-1].Buttonstate = true
        Question_Array[sender.tag-1].Countnum++
        
        var tmp = Question_Array[sender.tag-1].Message as NSString
        tmp = tmp + "<$#$>" + Question_Array[sender.tag-1].ID + "<$#$>" + String(Question_Array[sender.tag-1].Countnum)
        
        //var Send_Data = NSData(bytes: &Question_Array[sender.tag-1], length: sizeof(Question))
        var Send_Data = tmp.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        Send_Data = "ArrayEmpty".dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        Send_Data = "Empty".dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        
        Sort(sender.tag-1)
        
//        if Question_Array[sender.tag-1].Countnum > 2{
//            Speech(Question_Array[sender.tag-1].Message)
//        }
    }
    
    //recieve
    func Recieve(#Quest : Question){
        
        for i in 0...Question_Array.count{
            
            RecieveNum = i
            if Question_Array.count == i{
                var NewQuestion = Question(Message: Quest.Message, Image:nil, Countnum: Quest.Countnum, Buttonstate: false, Answer: [], Solved: false, ID: Quest.ID)
                Question_Array.append(NewQuestion)
                Input_Table.reloadData()
                var indexPath = NSIndexPath(forItem: Question_Array.count-1, inSection: 0)
                Input_Table.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)

                break
            }
            if Question_Array[i].Message == Quest.Message{
                if Question_Array[i].Countnum < Quest.Countnum{
                    Question_Array[i].Countnum = Quest.Countnum
                    Sort(i)
                    Input_Table.reloadData()
                    //Speech(Question_Array[i].Message)
                }
                else{
                //    Question_Array[i].Answer = Quest.Answer
                    break
                }
                break
            }
        }
        
    }
    
    //Sort
    func Sort(TAG : Int){
        
        var CurrantCount = Question_Array[TAG].Countnum
        var i : Int
        
        for i=TAG-1; i>=0; i-- {
            if CurrantCount >= Question_Array[i].Countnum {
                var tmp = Question_Array[i]
                Question_Array[i] = Question_Array[i+1]
                Question_Array[i+1] = tmp
            }
            else{
                break
            }
        }
        
        Input_Table.reloadData()
        var indexPath = NSIndexPath(forItem: i, inSection: 0)
        Input_Table.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    //speach
    func Speech(Message : NSString){
        var speechSynthesizer : AVSpeechSynthesizer = AVSpeechSynthesizer.alloc()
        var utterance = AVSpeechUtterance(string:Message)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        speechSynthesizer.speakUtterance(utterance)
    }
    
    //Not Save
    func CheckSave(){
        Save_Window.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        Save_Window.frame = CGRectMake(0, 0, width, height)
        Save_Window.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        
        Save_Window.makeKeyWindow()
        self.Save_Window.makeKeyAndVisible()
        
        var SaveLabel = UILabel(frame: CGRectMake(0, 0, width/1.28, height/2.84))
        SaveLabel.layer.position = CGPointMake(self.Save_Window.frame.width/2, self.Save_Window.frame.height/2)
        SaveLabel.text = "You don't save.\nDo you Save?"
        SaveLabel.numberOfLines = 0
        SaveLabel.textAlignment = NSTextAlignment.Center
        SaveLabel.textColor = UIColor.whiteColor()
        SaveLabel.font = UIFont.systemFontOfSize(35)
        self.Save_Window.addSubview(SaveLabel)
        
        OKButton = UIButton(frame: CGRectMake(0, 0, width/3.2, height/14.2))
        OKButton.backgroundColor = UIColor.orangeColor()
        OKButton.setTitle("Yes", forState: .Normal)
        OKButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        OKButton.layer.cornerRadius = 20.0
        OKButton.layer.position = CGPointMake(self.Save_Window.frame.width/6*5, self.Save_Window.frame.height-35)
        OKButton.addTarget(self, action: "SaveCheckButton:", forControlEvents: .TouchUpInside)
        self.Save_Window.addSubview(OKButton)
        
        NoButton = UIButton(frame: CGRectMake(0, 0, width/3.2, height/14.2))
        NoButton.backgroundColor = UIColor.orangeColor()
        NoButton.setTitle("No", forState: .Normal)
        NoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        NoButton.layer.cornerRadius = 20.0
        NoButton.layer.position = CGPointMake(self.Save_Window.frame.width/6*3, self.Save_Window.frame.height-35)
        NoButton.addTarget(self, action: "SaveCheckButton:", forControlEvents: .TouchUpInside)
        self.Save_Window.addSubview(NoButton)
        
        CancelButton = UIButton(frame: CGRectMake(0, 0, width/3.2, height/14.2))
        CancelButton.backgroundColor = UIColor.orangeColor()
        CancelButton.setTitle("Cancel", forState: .Normal)
        CancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        CancelButton.layer.cornerRadius = 20.0
        CancelButton.layer.position = CGPointMake(self.Save_Window.frame.width/6, self.Save_Window.frame.height-35)
        CancelButton.addTarget(self, action: "SaveCheckButton:", forControlEvents: .TouchUpInside)
        self.Save_Window.addSubview(CancelButton)

    }
    
    //Button push
    func SaveCheckButton(sender:UIButton){
        if sender == CancelButton{
            Save_Window.hidden = true
            return
        }
        if sender == OKButton{
            Save()
        }
        Save_Window.hidden = true
        Super_State = 0
        self.performSegueWithIdentifier("ToEnter", sender: self)
    }

    //-----------------------------------------------------------------------------
    
    /******
    Save Window(SuperState == 1)
    ******/

    //Save
    func Save(){
        
        //Date Setting
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateStyle = .ShortStyle
        var DATE = dateFormatter.stringFromDate(now)
        
        var summary = String(DATE) + ":"
        for i in 0..<Question_Array.count{
            summary = summary + Question_Array[i].Message + "#" + String(Question_Array[i].Countnum) + "#"
        }
        
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("data.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("Don't make file")
                return
            }
        }
        
        var FileData = NSMutableArray(contentsOfFile: filePath)
        
        
        if FileData != nil{
            var index = FileData?.indexOfObject(SubName)
            var i : Int
            if index != NSNotFound {
                for i=index!+1;i<FileData?.count;i++ {
                    var range = FileData?[i].rangeOfString("/")
                    if range?.location == NSNotFound{
                        FileData?.insertObject(summary, atIndex: i)
                        break
                    }
                    if i+1 == FileData?.count{
                        FileData?.addObject(summary)
                        break
                    }
                }
            }
            else{
                FileData?.addObject(SubName)
                FileData?.addObject(summary)
            }
            FileData?.writeToFile(filePath, atomically: true)
        }
        else{
            var FileData2 = NSMutableArray(array: [SubName,summary])
            println(FileData2)
            let A = FileData2.writeToFile(filePath, atomically: true)
            print(A)
        }
        
        Question_Array.removeAll(keepCapacity: true)
        
        Input_Table.reloadData()
        
        self.performSegueWithIdentifier("ToEnter", sender: self)

    }

    func BlockSaveFile(){
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("Block.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("Don't make file")
                return
            }
        }
        
        BlockList.writeToFile(filePath, atomically: true)
        
    }
    
    func getHttp(res:NSURLResponse?,data:NSData?,error:NSError?){
        var myData:NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        println(myData)
    }
    
    //-----------------------------------------------------------------------------
    
    /******
    Camera Window(SuperState == 2)
    ******/
    
    //make Camera window
    func Camera(sender:UIButton){
        Super_State = 2
        Camera_Window.frame = CGRectMake(0, 0, width, height)
        Camera_Window.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        Camera_Window.alpha = 1.0
        
        Camera_Window.makeKeyWindow()
        self.Camera_Window.makeKeyAndVisible()
        Camera_Session = AVCaptureSession()
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as AVCaptureDevice
            }
        }
        
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as AVCaptureDeviceInput
        
        Camera_Session.addInput(videoInput)
        myImage_Output = AVCaptureStillImageOutput()
        Camera_Session.addOutput(myImage_Output)
        
        Camera_Session.sessionPreset = AVCaptureSessionPresetMedium
        
        let myVideoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(Camera_Session) as AVCaptureVideoPreviewLayer
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.Camera_Window.layer.addSublayer(myVideoLayer)
        Camera_Session.startRunning()
        
        let myButton = UIButton(frame: CGRectMake(0,0,width/2.67,height/11.36))
        myButton.backgroundColor = UIColor.redColor();
        myButton.layer.masksToBounds = true
        myButton.setTitle("Shutter", forState: .Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height-50)
        myButton.addTarget(self, action: "CameraButton:", forControlEvents: .TouchUpInside)
        
        self.Camera_Window.addSubview(myButton);
        
    }
    
    //shutter
    func CameraButton(sender: UIButton){
        
        let myVideoConnection = myImage_Output.connectionWithMediaType(AVMediaTypeVideo)
        self.myImage_Output.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            self.myImage = UIImage(data: myImageData)!
            
            self.illust(self.myImage)
        })
        
    }

    
    //-----------------------------------------------------------------------------
    
    /******
    Illust Window(SuperState == 3)
    ******/
    
    //make illust window
    func illust(selfimage : UIImage){
        Super_State = 3
        
        Camera_Window.hidden = true
        Illust_Window.hidden = false
        
        Illust_Window.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        Illust_Window.frame = CGRectMake(0, 0, width, height)
        Illust_Window.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        Illust_Window.alpha = 1.0
        self.view.addSubview(Illust_Window)
        
        canvas_View = UIImageView(frame: CGRectMake(width/32, height/28.4, width/1.07, height/1.35))
        canvas_View.image = selfimage
        image = selfimage
        canvas_View.backgroundColor = UIColor.whiteColor()
        canvas_View.layer.borderWidth = 2
        canvas_View.layer.borderColor = UIColor.whiteColor().CGColor
        self.Illust_Window.addSubview(canvas_View)
        
        pre_Image = canvas_View.image
        
        var Save_Button = UIButton(frame: CGRectMake(width/1.49, height/1.12, width/3.2, height/11.36))
        Save_Button.backgroundColor = UIColor(red: 0.98, green: 0.66, blue: 0.28, alpha: 0.8)
        Save_Button.setTitle("Send", forState: .Normal)
        Save_Button.addTarget(self, action: "illustSend:", forControlEvents: .TouchUpInside)
        Save_Button.layer.borderWidth = 2
        Save_Button.layer.borderColor = UIColor.whiteColor().CGColor
        self.Illust_Window.addSubview(Save_Button)
        
        var Undo_Button = UIButton(frame: CGRectMake(width/2.91, height/1.12, width/3.2, height/11.36))
        Undo_Button.backgroundColor = UIColor.lightGrayColor()
        Undo_Button.setTitle("Undo", forState: .Normal)
        Undo_Button.addTarget(self, action: "pushed_undoButton:", forControlEvents: .TouchUpInside)
        Undo_Button.layer.borderColor = UIColor.whiteColor().CGColor
        Undo_Button.layer.borderWidth = 2
        self.Illust_Window.addSubview(Undo_Button)
        
        var Redo_Button = UIButton(frame: CGRectMake(width/64, height/1.12, width/3.2, height/11.36))
        Redo_Button.backgroundColor = UIColor.lightGrayColor()
        Redo_Button.setTitle("Redo", forState: .Normal)
        Redo_Button.addTarget(self, action: "pushed_redoButton:", forControlEvents: .TouchUpInside)
        Redo_Button.layer.borderWidth = 2
        Redo_Button.layer.borderColor = UIColor.whiteColor().CGColor
        self.Illust_Window.addSubview(Redo_Button)
        
        var Red_Button = UIButton(frame: CGRectMake(width/64, height/1.26, width/3.2, height/11.36))
        Red_Button.backgroundColor = UIColor(red: 0.91, green: 0.3, blue: 0.24, alpha: 0.8)
        Red_Button.setTitle("Red", forState: .Normal)
        Red_Button.addTarget(self, action: "pushed_RedButton:", forControlEvents: .TouchUpInside)
        Red_Button.layer.borderColor = UIColor.whiteColor().CGColor
        Red_Button.layer.borderWidth = 2
        self.Illust_Window.addSubview(Red_Button)
        
        var Green_Button = UIButton(frame: CGRectMake(width/2.91, height/1.26, width/3.2, height/11.36))
        Green_Button.backgroundColor = UIColor(red: 0.1, green: 0.74, blue: 0.61, alpha: 0.8)
        Green_Button.setTitle("Green", forState: .Normal)
        Green_Button.addTarget(self, action: "pushed_GreenButton:", forControlEvents: .TouchUpInside)
        Green_Button.layer.borderWidth = 2
        Green_Button.layer.borderColor = UIColor.whiteColor().CGColor
        self.Illust_Window.addSubview(Green_Button)
        
        var Blue_Button = UIButton(frame: CGRectMake(width/1.49, height/1.26, 100, height/11.36))
        Blue_Button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 0.8)
        Blue_Button.setTitle("Blue", forState: .Normal)
        Blue_Button.addTarget(self, action: "pushed_BlueButton:", forControlEvents: .TouchUpInside)
        Blue_Button.layer.borderColor = UIColor.whiteColor().CGColor
        Blue_Button.layer.borderWidth = 2
        self.Illust_Window.addSubview(Blue_Button)
        
    }
    
    //Draw (6 func)
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if Super_State == 3{
            let touch :UITouch = touches.anyObject() as UITouch
            touchedPoint = touch.locationInView(self.canvas_View)
            bezierPath = UIBezierPath()
            bezierPath.moveToPoint(touchedPoint)
            firstMovedFlag = true
            
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if Super_State == 3{
            if (bezierPath == nil){
                return;
            }
            let touch :UITouch = touches.anyObject() as UITouch
            let currentPoint = touch.locationInView(self.canvas_View)
            if firstMovedFlag {
                firstMovedFlag = false
                touchedPoint = currentPoint
                return
            }
            let middlePoint = self.midPoint(touchedPoint, point1: currentPoint)
            bezierPath.addQuadCurveToPoint(middlePoint, controlPoint: touchedPoint)
            self.drawLinePreview(currentPoint)
            touchedPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if Super_State == 3{
            if (bezierPath == nil){
                return;
            }
            let touch :UITouch = touches.anyObject() as UITouch
            let currentPoint = touch.locationInView(self.canvas_View)
            bezierPath.addQuadCurveToPoint(currentPoint, controlPoint: touchedPoint)
            self.drawline()
            bezierPath = nil;
        }
    }
    
    func drawLinePreview(endPoint:CGPoint){
        if Super_State == 3{
            UIGraphicsBeginImageContextWithOptions(canvas_View.bounds.size, false, 0.0)
            canvas_View.image?.drawInRect(canvas_View.bounds)
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.Penwidth)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),self.red,self.green,self.blue, self.alpha)
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchedPoint.x, touchedPoint.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), endPoint.x, endPoint.y)
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            canvas_View.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    func drawline(){
        if Super_State == 3{
            UIGraphicsBeginImageContextWithOptions(canvas_View.bounds.size, false, 0.0)
            image?.drawInRect(canvas_View.bounds)
            bezierPath.lineWidth = self.Penwidth
            bezierPath.lineCapStyle = kCGLineCapRound
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),self.red,self.green,self.blue, self.alpha)
            bezierPath.stroke()
            image = UIGraphicsGetImageFromCurrentImageContext()
            canvas_View.image = image
            
            into_undoArray()
            pre_Image = canvas_View.image
            
            UIGraphicsEndImageContext();
        }
    }
    
    func midPoint(point0:CGPoint, point1:CGPoint) ->CGPoint{
        let x = point0.x + point1.x
        let y = point0.y + point1.y
        return CGPointMake(x/2.0, y/2.0)
    }
    
    //Changecolor push (3 func)
    func pushed_RedButton(sender : UIButton){
        self.Penwidth = width/64
        self.red = 0.91
        self.green = 0.3
        self.blue = 0.24
        self.alpha = 0.8
    }
    
    func pushed_GreenButton(sender : UIButton){
        self.Penwidth = width/64
        self.red = 0.1
        self.green = 0.74
        self.blue = 0.61
        self.alpha = 0.8
    }
    
    func pushed_BlueButton(sender : UIButton){
        self.Penwidth = width/64
        self.red = 0.2
        self.green = 0.6
        self.blue = 0.86
        self.alpha = 0.8
    }
    
    //Undo (2 func)
    func into_undoArray(){
        if Image_array_undo.count == 11{
            for i in 0..<10{
                Image_array_undo[i] = Image_array_undo[i+1]
            }
        }
            
        else{
            Image_array_undo.append(pre_Image!)
        }
        
    }
    func pushed_undoButton(sender: UIButton){
        if Image_array_undo.count >= 1{
            into_redoArray()
            
            image = Image_array_undo[Image_array_undo.count-1]
            canvas_View.image = image
            pre_Image = image
            Image_array_undo.removeAtIndex(Image_array_undo.count-1)
        }
    }
    
    //Redo (2 func)
    func into_redoArray(){
        if Image_array_redo.count == 11{
            for i in 0..<10{
                Image_array_redo[i] = Image_array_redo[i+1]
            }
        }
        else{
            Image_array_redo.append(canvas_View.image!)
        }
        
    }
    func pushed_redoButton(sender: UIButton){
        if Image_array_redo.count >= 1{
            into_undoArray()
            
            image = Image_array_redo[Image_array_redo.count-1]
            canvas_View.image = image
            pre_Image = image
            Image_array_redo.removeAtIndex(Image_array_redo.count-1)
        }
    }
    
    //Send push
    func illustSend(sender : UIButton){
        let myIDforAd = myASManager.advertisingIdentifier
        
        Illust_Window.hidden = true
        Super_State = 0
        
        illustSet()
        
        var ImageData : NSData = UIImageJPEGRepresentation(image, 0.9)
        var imagemessage : NSString = NSString(format: "image %d", Question_Array.count-1)
        var tmp = imagemessage + "<$#$>" + myIDforAd.UUIDString + "<$#$>" + "0"
        var Send_Data = tmp.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        Send_Data = "ArrayEmpty".dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        self.mySession.sendData(ImageData, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
    }
    func illustSet(){
        let myIDforAd = myASManager.advertisingIdentifier
        
        var imagemessage : NSString = NSString(format: "image %d", Question_Array.count)
        var ImageData = UIImageJPEGRepresentation(image, 0.8)
        var NewQuestion = Question(Message: imagemessage, Image: image, Countnum: 0, Buttonstate: false, Answer: [], Solved: false, ID: myIDforAd.UUIDString)
        
        Question_Array.append(NewQuestion)
        Input_Table.reloadData()
        
        var indexPath = NSIndexPath(forItem: Question_Array.count-1, inSection: 0)
        Input_Table.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }

    /******
    tableView
    ******/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 1{
            Question_Num = indexPath.row
            details()
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if tableView.tag == 1{
//            Question_Num = indexPath.row
//        }
//    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return height/5.68
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1{
            return Question_Array.count
        }
        else{
            return Question_Array[Question_Num].Answer.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.tag == 1{
            var cell = Input_Table.dequeueReusableCellWithIdentifier("InputCell", forIndexPath: indexPath) as CustomTableViewCell
            if Question_Array[indexPath.row].Solved == true{
                cell.backgroundColor = UIColor.grayColor()
            }
            else{
                cell.backgroundColor = UIColor.whiteColor()
            }
            ButtonInit(Button: cell.Metoo!, Order: indexPath.row+1, State: Question_Array[indexPath.row].Buttonstate)
            if (Question_Array[indexPath.row].Image == nil){
                cell.Question?.numberOfLines = 0
                cell.Question?.font = UIFont.systemFontOfSize(width/18.8)
                cell.Question?.text = Question_Array[indexPath.row].Message
            }else{
                var tmp = Question_Array[indexPath.row].Image!
                var image = UIImage(CGImage: tmp.CGImage!, scale: tmp.scale, orientation: UIImageOrientation.Left)
                
                var attributedString = NSMutableAttributedString(string: "")
                var imgTextAttachment = NSTextAttachment()
                
                imgTextAttachment.image = image
                imgTextAttachment.bounds = CGRectMake(0, 0, width/1.78, height/6.68)
                
                var imgAttributedString = NSAttributedString(attachment: imgTextAttachment)
                attributedString.insertAttributedString(imgAttributedString, atIndex: 0)
                
                cell.Question?.attributedText = attributedString

            }
            var Gradation = CGFloat(Question_Array[indexPath.row].Countnum)
            Gradation = Gradation/5
            cell.Count?.textColor = UIColor(red: 0.0, green: Gradation, blue: 0.0, alpha: 1.0)
            cell.Count?.text = "\(Question_Array[indexPath.row].Countnum)"
            var IDStrtmp = Question_Array[indexPath.row].ID as NSString
            var DisplayIDStr = ""
            for i in 0..<5{
                DisplayIDStr = DisplayIDStr + IDStrtmp.substringWithRange(NSMakeRange(DisplayID[i], 1))
            }
            cell.ID?.text = DisplayIDStr
            return cell
        }else{
            var cell = Answer_Table.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            var AnswerData = Question_Array[Question_Num].Answer
            cell.textLabel?.text = AnswerData[indexPath.row]
            return cell
        }
    }
    
    
    //-----------------------------------------------------------------------------
    
    /******
    Detail Window(SuperState == 4)
    ******/
    
    //Make Detail Window
    func details(){
        Super_State = 4
        
        Detail_Window.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        Detail_Window.frame = CGRectMake(0, 0, width, height)
        Detail_Window.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        
        Detail_Window.makeKeyWindow()
        self.Detail_Window.makeKeyAndVisible()
        
        Answer_Table.frame = CGRectMake(0, 0, width/1.07, height/1.78)
        Answer_Table.layer.position = CGPointMake(width/2, height/1.58)
        Answer_Table.backgroundColor = UIColor.whiteColor()
        Answer_Table.delegate = self
        Answer_Table.dataSource = self
        Answer_Table.separatorColor = UIColor.clearColor()
        Answer_Table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        Answer_Table.tag = 2
        self.Detail_Window.addSubview(Answer_Table)
        
        DetailTextBack.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        DetailTextBack.frame = CGRectMake(0, height/1.1, width, height/11.36)
        self.Detail_Window.addSubview(DetailTextBack)
        
        Detail_Text.frame = CGRectMake(0, 0, width/1.33, height/18.93)
        Detail_Text.layer.position = CGPointMake(width/2.48, height/1.04)
        Detail_Text.borderStyle = UITextBorderStyle.RoundedRect
        Detail_Text.delegate = self
        Detail_Text.placeholder = "Write your Answer"
        self.Detail_Window.addSubview(Detail_Text)
        
        Answer_Button.frame = CGRectMake(0, 0, width/5.33, height/18.93)
        Answer_Button.layer.position = CGPointMake(width/1.14, height/1.04)
        Answer_Button.setImage(UIImage(named: "send.png"), forState: .Normal)
        Answer_Button.addTarget(self, action: "push_AnswerButton:", forControlEvents: .TouchUpInside)
        self.Detail_Window.addSubview(Answer_Button)
        
        Solved_Button.frame = CGRectMake(0, 0, width/10.67, height/10.72)
        Solved_Button.layer.position = CGPointMake(width/1.14, height/10.33)
        Solved_Button.setImage(UIImage(named: "resolve_before.png"), forState: .Normal)
        Solved_Button.setImage(UIImage(named: "resolve_after.png"), forState: .Disabled)
        Solved_Button.addTarget(self, action: "push_SolveButton:", forControlEvents: .TouchUpInside)
        if Question_Array[Question_Num].Solved{
            Solved_Button.enabled = false
        }
        else{
            Solved_Button.enabled = true
        }
        self.Detail_Window.addSubview(Solved_Button)
        
        Block_Button.frame = CGRectMake(0, 0, width/4, height/10.72)
        Block_Button.layer.position = CGPointMake(width/1.52, height/10.33)
        Block_Button.setImage(UIImage(named: "Block.png"), forState: .Normal)
        Block_Button.addTarget(self, action: "Push_BlockButton:", forControlEvents: .TouchUpInside)
        self.Detail_Window.addSubview(Block_Button)
        
        Question_Back.backgroundColor = UIColor.whiteColor()
        Question_Back.frame = CGRectMake(0, 0, width/1.07, height/6.45)
        Question_Back.layer.position = CGPointMake(width/2, height/3.92)
        self.Detail_Window.addSubview(Question_Back)
        
        Question_Label.frame = CGRectMake(0, 0, width/1.68, height/6.45)
        Question_Label.layer.position = CGPointMake(width/2, height/3.92)
        Question_Label.backgroundColor = UIColor.whiteColor()
        if Question_Array[Question_Num].Image == nil{
            Question_Label.textAlignment = NSTextAlignment.Center
            Question_Label.numberOfLines = 0
            Question_Label.text = Question_Array[Question_Num].Message
            self.Detail_Window.addSubview(Question_Label)
        }else{
            var tmp = Question_Array[Question_Num].Image!
            Question_Image = UIImage(CGImage: tmp.CGImage!, scale: tmp.scale, orientation: UIImageOrientation.Left)!
            
            var attributedString = NSMutableAttributedString(string: "")
            var imgTextAttachment = NSTextAttachment()
            
            imgTextAttachment.image = Question_Image
            imgTextAttachment.bounds = CGRectMake(0, 0, width/1.78, height/6.68)
            
            var imgAttributedString = NSAttributedString(attachment: imgTextAttachment)
            attributedString.insertAttributedString(imgAttributedString, atIndex: 0)
            
            Question_Label.attributedText = attributedString
            self.Detail_Window.addSubview(Question_Label)
            
            //拡大ボタン
            var expandButton = UIButton(frame: CGRectMake(0, 0, width/8, height/11.36))
            expandButton.layer.position = CGPointMake(width/1.14, height/3.44)
            image = UIImage(named: "Expand.png")
            expandButton.setImage(image, forState: .Normal)
            expandButton.addTarget(self, action: "Expand:", forControlEvents: .TouchUpInside)
            
            self.Detail_Window.addSubview(expandButton)
        }
        
        Back_Button.layer.position = CGPointMake(width/16, height/10.52)
        self.Detail_Window.addSubview(Back_Button)
        
        Answer_Table.reloadData()

    }
    
    //Answer button
    func push_AnswerButton(sender:UIButton){
        if countElements(Detail_Text.text) != 0 {
            ReloadView()
        }
    }
    func ReloadView(){
        Detail_Window.endEditing(true)
        var AnswerData = Question_Array[Question_Num].Answer
        AnswerData.append(Detail_Text.text)
        Question_Array[Question_Num].Answer = AnswerData
        Detail_Text.text = ""
        Answer_Table.reloadData()
        
        
        var tmp = Question_Array[Question_Num].Message as NSString
        tmp = tmp + "<$#$>" + Question_Array[Question_Num].ID + "<$#$>" + String(Question_Array[Question_Num].Countnum)
        
        //var Send_Data = NSData(bytes: &Question_Array[sender.tag-1], length: sizeof(Question))
        var Send_Data = tmp.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        var ArrayData = NSKeyedArchiver.archivedDataWithRootObject(AnswerData)
        self.mySession.sendData(ArrayData, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        Send_Data = "Empty".dataUsingEncoding(NSUTF8StringEncoding)
        self.mySession.sendData(Send_Data, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
        
    }
    
    //Solve button
    func push_SolveButton(sender:UIButton){
        sender.enabled = false
        Question_Array[Question_Num].Solved = true
        Input_Table.reloadData()
    }
    
    func Push_BlockButton(sender:UIButton){
        
        Super_State = 0
        self.Detail_Window.endEditing(true)
        Solved_Button.removeFromSuperview()
        Detail_Window.hidden = true
        Back_Button.frame = CGRectMake(width/32, height/15.35, width/16, height/16.23)
        self.view.addSubview(Back_Button)
        
        var BlockID = self.Question_Array[Question_Num].ID
        var BlockMessage = self.Question_Array[Question_Num].Message
        
        let alertController = UIAlertController(title: "このギモンに関して", message: "", preferredStyle: .ActionSheet)
        let ReportAction = UIAlertAction(title: "このギモンを報告する", style: .Default) {
            action in println("Pushed Second")
            let myIDforAd = self.myASManager.advertisingIdentifier
            var strtmpData = "FromID=" + myIDforAd.UUIDString + "&Content=" + BlockMessage + "&ToID=" + BlockID
            var strData = strtmpData.dataUsingEncoding(NSUTF8StringEncoding)
            
            var myUrl:NSURL = NSURL(string:"http://gimonkun.php.xdomain.jp/Gimonkun.php")!
            var myRequest = NSMutableURLRequest(URL: myUrl)
            
            myRequest.HTTPMethod = "POST"
            myRequest.HTTPBody = strData
            
            NSURLConnection.sendAsynchronousRequest(myRequest, queue: NSOperationQueue.mainQueue(), completionHandler: self.getHttp)
            
            
        }
        
        let BlockAction = UIAlertAction(title: "このIDの投稿をブロックする", style: .Default) {
            action in println("Pushed Second")
            var i : Int=0
            for (i=0;i<self.Question_Array.count;i++) {
                if self.Question_Array[i].ID == BlockID{
                    self.Question_Array.removeAtIndex(i)
                    i--
                }
            }
            self.Input_Table.reloadData()
            self.BlockList.addObject(BlockID)
            self.BlockList.addObject(BlockMessage)
            self.BlockSaveFile()
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
            action in println("Pushed CANCEL")
        }
        
        alertController.addAction(ReportAction)
        alertController.addAction(BlockAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController , animated: true, completion: nil)

    }
    
    //-----------------------------------------------------------------------------
    
    /******
    Expand Window(SuperState == 5)
    ******/
    
    //Expand Window
    func Expand(sender: UIButton){
        Super_State = 5
        self.Detail_Text.endEditing(true)
        
        Expand_Window.backgroundColor = UIColor.blackColor()
        Expand_Window.frame = CGRectMake(0, 0, width, height)
        Expand_Window.layer.position = CGPointMake(width/2, height/2)
        Expand_Window.makeKeyWindow()
        self.Expand_Window.makeKeyAndVisible()
        
        var Image_View = UIImageView(frame: CGRectMake(0, 0, width/1.07, height/1.05))
        Image_View.layer.position = CGPointMake(width/2, height/1.96)
        Image_View.image = Question_Array[Question_Num].Image!
        self.Expand_Window.addSubview(Image_View)
        
        Back_Button.layer.position = CGPointMake(width/16, height/10.52)
        self.Expand_Window.addSubview(Back_Button)
        
    }
    
    //-----------------------------------------------------------------------------
    

    /******
    Multipeer Conectivity
    ******/
    
    func startBrowsingInEmptyRoom(){
        if(self.mySession.connectedPeers.count == 0){
            self.myAdvertiser.stopAdvertisingPeer()
            self.mySession.disconnect()
            self.myBrowser.startBrowsingForPeers()
            //self.myAdvertiser.startAdvertisingPeer()
        }
    }
    
    // browser:foundPeer:withDiscoveryInfo:
    override func browser(browser: MCNearbyServiceBrowser!,
        foundPeer peerID: MCPeerID!,
        withDiscoveryInfo info: [NSObject : AnyObject]!){
            let encodedMsg = self.SubName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false);
            self.myBrowser.invitePeer(peerID, toSession: mySession, withContext: encodedMsg, timeout: 5);
    }
    
    // advertiser:didReceiveInvitationFromPeer:withContext:invitationHandler:
    override func advertiser(advertiser: MCNearbyServiceAdvertiser!,
        didReceiveInvitationFromPeer peerID: MCPeerID!,
        withContext context: NSData!,
        invitationHandler: ((Bool,
        MCSession!) -> Void)!){
            var foundedSubjectName = NSString(data: context, encoding: NSUTF8StringEncoding);
            //match SubName
            if(self.SubName == foundedSubjectName!){
                invitationHandler(true, mySession);
                println("Approve \(foundedSubjectName)'s invite ");
            }
    }
    
    
    // --------------------
    // MCSessionDelegate
    // --------------------
    
    // MCSession Delegate Methods
    
    // session:didReceiveData:fromPeer:
    override func session(session: MCSession!,
        didReceiveData data: NSData!,
        fromPeer peerID: MCPeerID!){
            
            if(BeforeData1 != data && BeforeData2 != data && BeforeData3 != data && BlockFlag == false){
                if(Counter == 0){
                    BeforeData1 = data
                    var receiveStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
                    var messageStr:NSArray = receiveStr.componentsSeparatedByString("<$#$>")
                    for i in 0..<BlockList.count {
                        if messageStr[1] as NSString == BlockList[i] as NSString{
                            BlockFlag = true
                            COUNTER2 = 0
                            return
                        }
                    }
                    var receiveNum = Int(messageStr[2].intValue)
                    var receiveData = Question(Message: messageStr[0] as NSString, Image:nil, Countnum: receiveNum, Buttonstate: false, Answer: [], Solved: false, ID:messageStr[1] as NSString)
                    //data.getBytes(&receiveData, length: sizeof(Question))
                    dispatch_async(dispatch_get_main_queue()){
                        self.Recieve(Quest: receiveData)
                    }
                    Counter = 1
                }else if(Counter == 1){
                    BeforeData2 = data
                    var Rec_Data = "ArrayEmpty".dataUsingEncoding(NSUTF8StringEncoding)
                    if(data != Rec_Data){
                        println("arrayrecive")
                        var AnswerData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [String]
                        Question_Array[RecieveNum].Answer = AnswerData
                        
                        let delay = 0.01 * Double(NSEC_PER_SEC)
                        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue(), {
                            self.Input_Table.reloadData()
                        })
                    }
                    Counter = 2

                }else if(Counter == 2){
                    BeforeData3 = data
                    var Rec_Data = "Empty".dataUsingEncoding(NSUTF8StringEncoding)
                    if(data != Rec_Data){
                        var receiveImg = UIImage(data: data)
                        Question_Array[RecieveNum].Image = receiveImg
                        
                        let delay = 0.01 * Double(NSEC_PER_SEC)
                        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue(), {
                            self.Input_Table.reloadData()
                        })
                    }
                    Counter = 0
                    dispatch_async(dispatch_get_main_queue()){
                        self.mySession.sendData(self.BeforeData1, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
                        self.mySession.sendData(self.BeforeData2, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
                        self.mySession.sendData(self.BeforeData3, toPeers: self.mySession.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: nil)
                    }
                    BeforeData1 = NSData()
                    BeforeData2 = NSData()
                    BeforeData3 = NSData()
                }
             }
            if BlockFlag == true{
               COUNTER2++
                if COUNTER2 == 2{
                    BlockFlag = false
                }
            }
    }
    
    // session:peer:didChangeState:
    override func session(session: MCSession!,
        peer peerID: MCPeerID!,
        didChangeState state: MCSessionState){

            if(state == MCSessionState.Connected){
                println("Move Conected State");
                /*
                [NSThread detachNewThreadSelector:@selector(MyConnectedToPeer) toTarget:self withObject:nil];
                */
                dispatch_async(dispatch_get_main_queue()){
                    //self.myAdvertiser.stopAdvertisingPeer();
                    //self.myBrowser.startBrowsingForPeers();
                    //var PEER = [peerID]
                    //Send Data for New Menber
                    //self.exchange_NSData(PEER)
                }
            }
            dispatch_async(dispatch_get_main_queue()){
                var connectionNum : Int = session.connectedPeers.count + 1;
                self.subName_Label.text = self.SubName
                self.Population.text = "\(connectionNum)"
            }
    }
    
}

