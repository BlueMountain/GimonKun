//
//  Content.swift
//  Gimon_kun Ver3.0
//
//  Created by Takuro Mori on 2014/10/21.
//  Copyright (c) 2014年 Takuro Mori. All rights reserved.
//

import UIKit
import Foundation

class Content: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var Sectnum : Int = 0
    var Rownum : Int = 0
    var CurrantData : Int = 0
    var tableView = UITableView()
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0

    //Array def
    var ContentList : [String] = [String]()
    var CountList : [String] = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        
        width = self.view.frame.width
        height = self.view.frame.height
        
        tableView.frame = CGRectMake(0, height/5.68, width, height/1.35)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        var nib = UINib(nibName: "CustomTableviewCell2", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "OutputCell")
        tableView.separatorColor = UIColor.clearColor()
        self.view.addSubview(tableView)
        
        var BackButton = UIButton(frame: CGRectMake(width/32, height/15.35, width/16, height/16.23))
        BackButton.setImage(UIImage(named: "back.png"), forState: .Normal)
        BackButton.addTarget(self, action: "BackButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(BackButton)
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return height/6.45
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContentList.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            UploadFile(indexPath.row)
            ContentList.removeAtIndex(indexPath.row)
            CountList.removeAtIndex(indexPath.row)
            tableView.reloadData()
        } else if editingStyle == UITableViewCellEditingStyle.Insert {
            // ここは空のままでOKです。
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
 
        
        let cell : CustomTableviewCell2 = self.tableView.dequeueReusableCellWithIdentifier("OutputCell") as CustomTableviewCell2
        
        cell.SaveQuestion?.numberOfLines = 0
        cell.SaveQuestion?.text = ContentList[indexPath.row]
        cell.SaveCount?.text = CountList[indexPath.row]
        
        return cell
    }
    
    func BackButton(sender:UIButton){
        goBack()
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
                println("ファイルの作成に失敗")
                return
            }
        }
        
        var DataArray = NSMutableArray(contentsOfFile: filePath)
        
        var range : NSRange
        
        if flag{
            ContentList.removeAll(keepCapacity: true)
            CountList.removeAll(keepCapacity: true)
        }
        
        var i = 0
        var j = 0
        var k = -1
        var CountFlag = false
        
        if DataArray != nil{
            for data in DataArray!{
                range = data.rangeOfString("/")
                if range.location != NSNotFound{
                    if k == Sectnum{
                        var Array = data.componentsSeparatedByString(":")
                        if j == Rownum {
                            CountFlag = true
                            Array = Array[1].componentsSeparatedByString("#")
                            for question in Array{
                                if i%2==0 && question as NSString != ""{
                                    ContentList.append(question as NSString)
                                    i++
                                }
                                else if question as NSString != ""{
                                    CountList.append(question as NSString)
                                    i++
                                }
                            }
                        }
                        j++
                    }
                }
                else{
                    k++
                }
                if !CountFlag{
                    CurrantData++
                }
            }
        }
        
    }
    
    func UploadFile(num : Int){
        
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("data.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("ファイルの作成に失敗")
                return
            }
        }
        
        var Keyword = ContentList[num] + "#" + CountList[num] + "#"
        
        var DataArray = NSMutableArray(contentsOfFile: filePath)
        var range : NSRange = DataArray![CurrantData].rangeOfString(Keyword)
        var str : NSString = DataArray![CurrantData] as NSString
        
        println("--------------------------------------------")
        println(Keyword)
        println(CurrantData)
        println(DataArray)
        
        DataArray![CurrantData] = str.stringByReplacingCharactersInRange(range, withString: "")
        
        println(DataArray![CurrantData])
        
        range = DataArray![CurrantData].rangeOfString("#")
        if range.location == NSNotFound{
            DataArray!.removeObjectAtIndex(CurrantData)
            DataArray?.writeToFile(filePath, atomically: true)
            goBack()
        }
        
        DataArray?.writeToFile(filePath, atomically: true)
        //FileOpen(true)
    }
}