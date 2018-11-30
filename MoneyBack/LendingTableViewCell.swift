//
//  LendingTableViewCell.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 26/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit

class LendingTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var lendingTitle: UILabel!
    @IBOutlet weak var lendingAmount: UILabel!
    @IBOutlet weak var lendingDate: UILabel!
    @IBOutlet weak var lendingContact: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
