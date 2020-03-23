//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    func taskTextFieldChanged(cell: TaskTableViewCell, textField: UITextField, newCaption: String?, oldCaption: String?)
}

class TaskTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath?
    
    var oldCaption = ""
    
    var delegate: TaskCellDelegate?
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskCheckButton: UIButton!
    
    
    
    func fetchInput() -> String? {
        if let caption = taskTextField.text {
            return caption
        }
        return nil
    }
    
    func saveCaption() {
        if let caption = taskTextField.text {
            oldCaption = caption
        }
    }
    
    @IBAction func taskEditBegun(_ sender: Any) {
        saveCaption()
    }
    
    @IBAction func taskValueChanged(_ sender: Any) {
        let textField = sender as? UITextField
        
        if let textField = textField {
            let cell = textField.superview?.superview as! TaskTableViewCell
            let textField = sender as! UITextField
            let newCaption = fetchInput()
            
            delegate?.taskTextFieldChanged(cell: cell, textField: textField, newCaption: newCaption, oldCaption: oldCaption)
        }
    }
    
    
    @IBAction func taskCheckButtonTapped(_ sender: Any) {
        taskTextField.isUserInteractionEnabled = false
        print("Task button clicked!")
    }
}
