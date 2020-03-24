//
//  CellFunctions.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 24/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class CellFunctions {
    
    func fetchInput(textField: UITextField) -> String? {
        if let caption = textField.text {
            return caption
        }
        return nil
    }
    
}
