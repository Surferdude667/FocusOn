//
//  HistoryGoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 11/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class HistoryGoalCell: UITableViewCell {
    
    @IBOutlet weak var checkMarkImage: UIImageView!
    @IBOutlet weak var goalTitleLabel: UILabel!
    @IBOutlet weak var background: CornerRadiusView!
    
    var goal: Goal!
    
    func setGoalCheckMark() {
        if goal.completed {
            checkMarkImage.image = #imageLiteral(resourceName: "checkmark.pdf")
            checkMarkImage.tintColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
            goalTitleLabel.textColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
        } else {
            checkMarkImage.image = #imageLiteral(resourceName: "circle.pdf")
            checkMarkImage.tintColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
            goalTitleLabel.textColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
        }
    }
    
    func configure() {
        background.layer.borderWidth = 1
        background.layer.borderColor = #colorLiteral(red: 0.172999993, green: 0.172999993, blue: 0.1800000072, alpha: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
}
