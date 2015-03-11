//
//  Output.swift
//  NewGimonKun
//
//  Created by Takuro Mori on 2014/11/26.
//  Copyright (c) 2014 Takuro Mori. All rights reserved.
//

import UIKit

class Output: UIViewController, UITableViewDelegate, UITableViewDataSource{
 
    //initialize
    //-----------------------------------------------------------------------------
    //general func
    
    var tableView = UITableView()
    var Sectnum : Int = 0
    var Rownum : Int = 0
    
    var sectionList : [String] = [String]()
    var DateList : [String] = [String]()
    var MacroDate : [NSArray] = [NSArray]()

    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    
    //-----------------------------------------------------------------------------
    //-----------------------------------------------------------------------------
    
    /******
    general func
    ******/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
                
        width = self.view.frame.width
        height = self.view.frame.height

        
        tableView.frame = CGRectMake(0, height/5.68, width, height/1.35)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clearColor()
        self.view.addSubview(tableView)
        
        
        var ContentLabel = UILabel(frame: CGRectMake(width/4.64, height/13.52, width/1.62, height/18.9))
        ContentLabel.textAlignment = NSTextAlignment.Center
        ContentLabel.font = UIFont.boldSystemFontOfSize(30)
        ContentLabel.textColor = UIColor.whiteColor()
        ContentLabel.text = "SaveData"
        self.view.addSubview(ContentLabel)
        
        var ReloadButton = UIButton(frame: CGRectMake(width/1.14, height/14.95, width/10.7, height/16.23))
        ReloadButton.setImage(UIImage(named: "reload.png"), forState: .Normal)
        ReloadButton.addTarget(self, action: "ReloadButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(ReloadButton)
        
        FileOpen(false)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        FileOpen(true)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        Sectnum = indexPath.section
        Rownum = indexPath.row
        
        self.performSegueWithIdentifier("toViewController", sender: self)
    }
    
    //return num of sction
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section] as String
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < MacroDate.count{
            return MacroDate[section].count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "\(MacroDate[indexPath.section][indexPath.row])"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toViewController"{
            var VC : Content = segue.destinationViewController as Content
            VC.Rownum = Rownum
            VC.Sectnum = Sectnum
        }
    }
    
    //Reload Button
    func ReloadButton(sender : AnyObject){
        FileOpen(true)
        tableView.reloadData()
    }
    
    //FileOpen
    func FileOpen(flag : Bool){
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("data.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("miss make file")
                return
            }
        }
        
        var DataArray = NSMutableArray(contentsOfFile: filePath)
        
        println(DataArray)
        
        var range : NSRange
        
        if flag{
            sectionList.removeAll(keepCapacity: true)
            MacroDate.removeAll(keepCapacity: true)
            DateList.removeAll(keepCapacity: true)
        }
        
        var Existflag : Bool = true
        var i = 0
        var j = 0
        
        if DataArray != nil{
            for data in DataArray!{
                range = data.rangeOfString("/")
                if range.location == NSNotFound{
                    sectionList.append(String(data as NSString))
                    if DateList.count != 0 {
                        MacroDate.append(DateList)
                        DateList.removeAll(keepCapacity: true)
                    }
                    if !Existflag{
                        sectionList.removeAtIndex(i-1)
                        DataArray?.removeObjectAtIndex(j-1)
                        DataArray?.writeToFile(filePath, atomically: true)
                        i--
                    }
                    Existflag = false
                    i++
                }
                else{
                    Existflag = true
                    var Array = data.componentsSeparatedByString(":")
                    DateList.append(Array[0] as NSString)
                }
                j++
            }
            if j == DataArray?.count && Existflag == false{
                DataArray?.removeObjectAtIndex(j-1)
                sectionList.removeAtIndex(i-1)
                DataArray?.writeToFile(filePath, atomically: true)
            }
        }
        MacroDate.append(DateList)
        
    }
}