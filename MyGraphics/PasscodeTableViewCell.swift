//
//  PasscodeTableViewCell.swift
//  MyGraphics
//
//  Created by Linsw on 16/1/20.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class PasscodeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var enablePasscodeSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
