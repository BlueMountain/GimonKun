//
//  CustomTableViewCell.swift
//  NewGimonKun
//
//  Created by Takuro Mori on 2014/11/28.
//  Copyright (c) 2014 Takuro Mori. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet var Question : UILabel?
    @IBOutlet var Metoo : UIButton?
    @IBOutlet var Count : UILabel?
    @IBOutlet var ID : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
