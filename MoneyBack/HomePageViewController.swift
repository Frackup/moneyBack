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
    var appUser: AppUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homePageLabel.text = "Argent actuellement prêté"
        homePageLendDetailButton.layer.cornerRadius = 5
        homePageLendButton.setTitle("Ajouter un prêt", for: .normal)
        homePageLendButton.layer.cornerRadius = 5
        
        let button = createSettingsBtn()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        // Load any saved lendings.
        if let savedLendings = loadLendings() {
            lendings += savedLendings
        }
        
        if let myUser = appUser {
            appUser = myUser
            os_log("User correctly passed to HomePageViewController", log: OSLog.default, type: .debug)
        } else {
            guard let myUser = loadAppUser() else {
                fatalError("The user should have already been created")
            }
            appUser = myUser
            os_log("User correctly loaded on HomePageViewController", log: OSLog.default, type: .debug)
        }

        updateMoneyButton()
    }
    
    //MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddLending":
            os_log("Adding a new lending.", log: OSLog.default, type: .debug)
            
        case "ShowSettings":
            os_log("Going to settings page.", log: OSLog.default, type: .debug)
            
        case "ShowLendingsList":
            guard let lendingTableViewController = segue.destination as? LendingTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            lendingTableViewController.lendingsList = lendings
            lendingTableViewController.appUser = appUser
            
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    }

    //MARK: Actions
    // This function is dealing with calling back the homePage once a lending has been created
    @IBAction func unwindToHomePage(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LendingViewController, let lending = sourceViewController.lending {

            appUser?.totalAmount += lending.amount
            updateMoneyButton()
            // Save tne lendings.
            lendings.append(lending)
            saveLendings()
            saveAppUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let savedLendings = loadLendings() {
            lendings = savedLendings
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
    
    func updateMoneyButton() {
        guard let amount = appUser?.totalAmount else {
            fatalError("The user has not been loaded or does not contain any totalAmount variable")
        }
        homePageLendDetailButton.setTitle(String(amount) + " €", for: .normal)
    }
    
    private func loadAppUser() -> AppUser? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppUser.ArchiveURL.path) as? AppUser
    }
    
    func saveAppUser() {
        let isSuccessfullSave = NSKeyedArchiver.archiveRootObject(appUser, toFile: AppUser.ArchiveURL.path)
        
        if isSuccessfullSave {
            os_log("User successfully saved by HomePageViewController", log:OSLog.default, type: .debug)
            print(appUser?.totalAmount)
        } else {
            os_log("Failed to save user in HomePageViewController...", log:OSLog.default, type: .error)
        }
    }
    
    func createSettingsBtn() -> UIButton {
        //create a new button
        let button = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "settings"), for: .normal)
        button.imageView?.tintColor = UIColor.blue
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        button.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return button
    }
    
    @objc func goToSettings() {
        self.performSegue(withIdentifier: "ShowSettings", sender: self)
    }
}

/*extension UIBarButtonItem {
    class func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}*/
