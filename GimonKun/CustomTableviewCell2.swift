//
//  CustomTableviewCell2.swift
//  NewGimonKun
//
//  Created by Takuro Mori on 2014/12/05.
//  Copyright (c) 2014年 Takuro Mori. All rights reserved.
//

import UIKit

class CustomTableviewCell2: UITableViewCell {

    @IBOutlet var SaveQuestion : UILabel?
    @IBOutlet var SaveCount : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
