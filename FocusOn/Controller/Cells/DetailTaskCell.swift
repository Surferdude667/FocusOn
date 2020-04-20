//
//  DetailTaskCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 12/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class DetailTaskCell: UITableViewCell {
    
    @IBOutlet weak var taskCheckmarkImage: UIImageView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    var task: Task!
    
    func setTaskCheckMark() {
        if task.completed {
            taskCheckmarkImage.image = #imageLiteral(resourceName: "checkmark.pdf")
            taskCheckmarkImage.tintColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
            taskTitleLabel.textColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
        } else {
            taskCheckmarkImage.image = #imageLiteral(resourceName: "circle.pdf")
            taskCheckmarkImage.tintColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
            taskTitleLabel.textColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
        }
    }
    
}
