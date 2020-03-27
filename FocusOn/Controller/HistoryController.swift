//
//  HistoryController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 18/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

class HistoryController: UIViewController {

    var goals = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        printTest()
        
    }
    
    func printTest() {
        print("HA")
        for i in 0..<goals.count {
            
            print(goals[i].value(forKey: "tasks") as! [String])
        }
    }
    
    func fetch() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Goal")
        
        do {
            goals = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetch()
    }
    @IBAction func test(_ sender: Any) {
        printTest()
    }
}
