//
//  AsksTableViewCell.swift
//  BenevolentlyAsk
//
//  Created by Dwayne Kurfirst on 3/31/17.
//  Copyright © 2017 kurfirstcorp. All rights reserved.
//

import UIKit

class AsksTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var ask: UITextView!
    
    @IBOutlet weak var believes: UILabel!
    
    
    @IBOutlet weak var believe: UIButton!
    
    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var report: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
