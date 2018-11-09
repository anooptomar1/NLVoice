//
//  CustomCell.swift
//  NLPVoiceMemo
//
//  Created by Anoop tomar on 4/4/18.
//  Copyright © 2018 Devtechie. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
