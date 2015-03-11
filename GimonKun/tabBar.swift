//
//  tabBar.swift
//  Gimon_kun Ver3.0
//
//  Created by Takuro Mori on 2014/11/20.
//  Copyright (c) 2014年 Takuro Mori. All rights reserved.
//

import Foundation
import UIKit

class tabBar : UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = UIColor(red: 0.05, green: 0.48, blue: 0.77, alpha: 1.0)
        
        let font:UIFont! = UIFont(name:"HelveticaNeue-Bold",size:10)
        
        let selectedAttributes2:NSDictionary! = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes2, forState: UIControlState.Normal)
        
        
        let selectedAttributes1:NSDictionary! = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(red: 0.94, green: 0.66, blue: 0.28, alpha: 1.0)]
        
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes1, forState: UIControlState.Selected)
        UITabBar.appearance().tintColor = UIColor(red: 0.94, green: 0.66, blue: 0.28, alpha: 1.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}