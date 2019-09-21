//
//  TwoTreesCustomCell.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 31/8/16.
//  Copyright © 2016 Abdulrahman Alattas. All rights reserved.
//

import UIKit

class TwoTreesCustomCell: UITableViewCell {
    @IBOutlet var lblCenter: UILabel!
    @IBOutlet var lblRight: UILabel!
    @IBOutlet var lblLeft: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}