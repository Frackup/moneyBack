//
//  ViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 21/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class HomePageViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var homePageLabel: UILabel!
    @IBOutlet weak var homePageLendButton: UIButton!
    @IBOutlet weak var homePageLendDetailButton: UIButton!
    var lendings = [Lending]()
    //var appUser = AppUser()
    var money = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homePageLabel.text = "Argent actuellement prêté"
        homePageLendDetailButton.layer.cornerRadius = 5
        
        homePageLendButton.setTitle("Ajouter un prêt", for: .normal)
        homePageLendButton.layer.cornerRadius = 5
        
        // Load any saved meals, otherwise load sample data.
        if let savedLendings = loadLendings() {
            lendings += savedLendings
            /*for lending in lendings {
                money += lending.amount
            }*/
        }
        
        /*if let user = loadAppUser() {
            appUser = user
        } else {
            appUser = AppUser(totalAmount: 0, paypalConnected: false)
        }*/

        updateMoneyButton()
    }
    
    //MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddLending":
            os_log("Adding a new lending.", log: OSLog.default, type: .debug)
            
        case "ShowLendingsList":
            guard let lendingTableViewController = segue.destination as? LendingTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            lendingTableViewController.lendingsList = lendings
            
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    }

    //MARK: Actions
    // This function is dealing with calling back the homePage once a lending has been created
    @IBAction func unwindToHomePage(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LendingViewController, let lending = sourceViewController.lending {
            
            money += lending.amount
            updateMoneyButton()
            // Save tne lendings.
            lendings.append(lending)
            saveLendings()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let savedLendings = loadLendings() {
            lendings = savedLendings
            money = 0
            for lending in lendings {
                money += lending.amount
            }
            updateMoneyButton()
        }
    }
    
    //MARK: Private Methods
    func saveLendings() {
        let isSuccessfullSave = NSKeyedArchiver.archiveRootObject(lendings, toFile: Lending.ArchiveURL.path)
        
        if isSuccessfullSave {
            os_log("Lendings successfully saved", log:OSLog.default, type: .debug)
        } else {
            os_log("Failed to save lendings...", log:OSLog.default, type: .error)
        }
    }
    
    private func loadLendings() -> [Lending]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Lending.ArchiveURL.path) as? [Lending]
    }
    
    private func loadAppUser() -> AppUser? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppUser.ArchiveURL.path) as? AppUser
    }
    
    func updateMoneyButton() {
        homePageLendDetailButton.setTitle(String(money) + " €", for: .normal)
    }

}

