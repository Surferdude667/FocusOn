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
    
    var goal: Goal!
    
    func setGoalCheckMark() {
        if goal.completed {
            checkMarkImage.backgroundColor = UIColor.green
        } else {
            checkMarkImage.backgroundColor = UIColor.red
        }
    }
}
