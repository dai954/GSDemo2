//
//  MessageCell.swift
//  GSDeomo
//
//  Created by 石川大輔 on 2021/04/08.
//

import UIKit

class MessageCell: UITableViewCell {

    
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightBottomLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
