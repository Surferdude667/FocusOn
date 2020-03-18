//
//  ViewController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //  MARK:- TableView
    
    //  Return the number of sections in table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    //  Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        
        cell1.textLabel?.text = "Cell text"
        return cell1
    }
    
    
    
    func configure() {
        print("Today")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

}

