//
//  DetailGoalCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 12/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class DetailGoalCell: UITableViewCell {
    
    @IBOutlet weak var goalCheckmarkImage: UIImageView!
    @IBOutlet weak var goalTitleLabel: UILabel!
    
    var goal: Goal!
    
    func setGoalCheckMark() {
        if goal.completed {
            goalCheckmarkImage.backgroundColor = UIColor.green
        } else {
            goalCheckmarkImage.backgroundColor = UIColor.red
        }
    }
    
}