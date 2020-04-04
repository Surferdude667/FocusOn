//
//  CellProtocol.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 04/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

protocol CellDelegate {
    func cellChanged(at indexPath: IndexPath)
    func cellAdded(at indexPath: IndexPath)
}
