//
//  CellModifier.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class CellModifier {
    
    static func lockUnlockTextField(textField: UITextField?, locked: Bool) -> UITextField? {
        if let textField = textField {
            let field = textField
            
            if locked == true {
                field.isUserInteractionEnabled = false
            } else {
                field.isUserInteractionEnabled = true
            }
            
            return field
        }
        return nil
    }
    
}
