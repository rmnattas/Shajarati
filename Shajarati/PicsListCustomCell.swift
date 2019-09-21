//
//  PicsListCustomCell.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 18/3/16.
//  Copyright © 2016 Abdulrahman Alattas. All rights reserved.
//

import UIKit

class PicsListCustomCell: UITableViewCell {
    @IBOutlet var lblname: UILabel!
    @IBOutlet var imgperson: UIImageView!
    
    @IBOutlet var imgFacebook: UIImageView!
    @IBOutlet var imgTwitter: UIImageView!
    @IBOutlet var imgEmail: UIImageView!
    @IBOutlet var imgWhatsapp: UIImageView!
    @IBOutlet var imgPersonText: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}