//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    func taskTextFieldChangedForCell(cell: TaskTableViewCell, newCaption: String?, oldCaption: String?)
    func taskCheckMarkChangedForCell(cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: TaskCellDelegate?
    var indexPath: IndexPath?
    var oldCaption: String?
    var task: Task?
    var goal: Goal?
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskCheckButton: UIButton!
    
    func configure() {
        taskTextField.delegate = self
    }
    
    func processInput(from textField: UITextField?) {
        if let textField = textField {
            let cell = textField.superview?.superview as! TaskTableViewCell
            let newCaption = CellFunctions().fetchInput(textField: textField)
            
            print("New Caption: \(newCaption) Old Caption: \(oldCaption)")
            delegate?.taskTextFieldChangedForCell(cell: cell, newCaption: newCaption, oldCaption: oldCaption)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    
    @IBAction func taskEditBegun(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            oldCaption = CellFunctions().fetchInput(textField: textField)
        }
    }
    
    @IBAction func taskEditEnded(_ sender: Any) {
        let textField = sender as? UITextField
        processInput(from: textField)
    }
    
    @IBAction func taskCheckButtonTapped(_ sender: Any) {
        //taskTextField.isUserInteractionEnabled = false
        delegate?.taskCheckMarkChangedForCell(cell: self)
    }
}
