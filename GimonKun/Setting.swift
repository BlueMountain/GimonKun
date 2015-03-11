//
//  Setting.swift
//  GimonKun
//
//  Created by Takuro Mori on 2015/02/01.
//  Copyright (c) 2015 Takuro Mori. All rights reserved.
//

import UIKit

class Setting: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    
    var subName_Label = UILabel()
    var tableView = UITableView()
    
    var BlockList = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        
        width = self.view.frame.width
        height = self.view.frame.height
        
        println(width)
        println(height)
        
        var BackImage = UIImageView(frame: CGRectMake(0, height/5.68, width, height/1.35))
        BackImage.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(BackImage)
        
        tableView.frame = CGRectMake(0, height/2.84, width, height/1.67)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clearColor()
        self.view.addSubview(tableView)

        var ContentLabel = UILabel(frame: CGRectMake(width/4.64, height/13.52, width/1.62, height/18.9))
        ContentLabel.textAlignment = NSTextAlignment.Center
        ContentLabel.font = UIFont.boldSystemFontOfSize(30)
        ContentLabel.textColor = UIColor.whiteColor()
        ContentLabel.text = "Setting"
        self.view.addSubview(ContentLabel)
        
        
        var DescriptionLabel = UILabel(frame: CGRectMake(width/32,height/5.68, width/1.07, height/11.36))
        DescriptionLabel.numberOfLines = 0
        DescriptionLabel.text="ブロックしたIDの投稿"
        DescriptionLabel.textAlignment = NSTextAlignment.Center
        DescriptionLabel.font = UIFont.boldSystemFontOfSize(20)
        DescriptionLabel.textColor = UIColor.blackColor()
        self.view.addSubview(DescriptionLabel)
        
        var DescriptionLabel2 = UILabel(frame: CGRectMake(width/32, height/4.21, width/1.07, height/11.36))
        DescriptionLabel2.numberOfLines = 0
        DescriptionLabel2.text="ブロックを解除する場合はタッチして下さい"
        DescriptionLabel2.textAlignment = NSTextAlignment.Center
        DescriptionLabel2.font = UIFont.boldSystemFontOfSize(14)
        DescriptionLabel2.textColor = UIColor.blackColor()
        self.view.addSubview(DescriptionLabel2)
        
        OpenFile()
        println(BlockList)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: "IDブロックに関して", message: "このIDのブロックを解除しますか？", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) {
            action in println("pushed OK!")
            println(self.BlockList)
            self.BlockList.removeObjectAtIndex(indexPath.row)
            self.BlockList.removeObjectAtIndex(indexPath.row)
            self.SaveFile()
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
            action in println("Pushed CANCEL!")
        }
        
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlockList.count/2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = String(BlockList[indexPath.row*2+1] as NSString)
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func OpenFile(){
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("Block.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("miss make file")
                return
            }
        }
        
        var FileData = NSMutableArray(contentsOfFile: filePath)
        if FileData != nil{
            BlockList = FileData!
        }
    }
    
    func SaveFile(){
        //File Open
        let documentdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = documentdir.stringByAppendingPathComponent("Block.plist")
        let fileManager = NSFileManager.defaultManager()
        
        //file exist?
        if !fileManager.fileExistsAtPath(filePath){
            let result : Bool = fileManager.createFileAtPath(filePath, contents:NSData(), attributes: nil)
            if !result{
                println("miss make file")
                return
            }
        }

        BlockList.writeToFile(filePath, atomically: true)
    }
}
