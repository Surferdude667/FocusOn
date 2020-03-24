//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

protocol GoalCellDelegate {
    func goalTextFieldChangedForCell(cell: GoalTableViewCell, newCaption: String?, oldCaption: String?)
}

class GoalTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath?
    var oldCaption: String?
    var delegate: GoalCellDelegate?
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalCheckButton: UIButton!
    
    
    @IBAction func goalEditBegun(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            oldCaption = CellFunctions().fetchInput(textField: textField)
        }
    }
    
    @IBAction func goalEditEnded(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            let cell = textField.superview?.superview as! GoalTableViewCell
            let newCaption = CellFunctions().fetchInput(textField: textField)
            
            delegate?.goalTextFieldChangedForCell(cell: cell, newCaption: newCaption, oldCaption: oldCaption)
            //goalTextField.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func goalCheckButtonTapped(_ sender: Any) {
        print("Goal checked!")
    }
}
