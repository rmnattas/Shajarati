//
//  CustomCell.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 29/12/15.
//  Copyright © 2015 Abdulrahman Alattas. All rights reserved.
//

import UIKit

class MyCustomCell: UITableViewCell {
    @IBOutlet var lblspaces: UILabel!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var imgperson: UIImageView!
    
    @IBOutlet var imginsta: UIImageView!
    @IBOutlet var imgsnap: UIImageView!
    @IBOutlet var imgfacebook: UIImageView!
    @IBOutlet var imgtwitter: UIImageView!
    @IBOutlet var imgemail: UIImageView!
    @IBOutlet var imgwhatsapp: UIImageView!
    @IBOutlet var imgpersontext: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}