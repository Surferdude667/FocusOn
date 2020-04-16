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
            taskCheckmarkImage.backgroundColor = UIColor.green
        } else {
            taskCheckmarkImage.backgroundColor = UIColor.red
        }
    }
    
}