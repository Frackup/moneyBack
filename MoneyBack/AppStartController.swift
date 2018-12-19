//
//  AppStartController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 04/12/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class AppStartController: UIViewController {
    
    @IBOutlet weak var onboardingContainer: UIView!
    var appUser: AppUser!
    var window: UIWindow?
    
    @IBAction func skipOnboarding(_ sender: UIButton) {
        sender.removeFromSuperview()
        onboardingContainer.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create a new user
        os_log("Creating a new user", log: OSLog.default, type: .debug)
        saveAppUser()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "GoToHomePage":
            os_log("Going to the home page.", log: OSLog.default, type: .debug)
            
            /*guard let navVC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let homePageViewController = navVC.topViewController as? HomePageViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }*/
            
            //homePageViewController.appUser = appUser
            
        case "displayOnboarding":
            os_log("Displaying onboarding screen.", log: OSLog.default, type: .debug)
            
            /*guard let onboardingController = segue.destination as? OnboardingViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }*/
            
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    }
    
    //MARK: Private Methods
    private func loadAppUser() -> AppUser? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppUser.ArchiveURL.path) as? AppUser
    }
    
    func saveAppUser() {
        let isSuccessfullSave = NSKeyedArchiver.archiveRootObject(AppUser(totalAmount: 0, paypalConnected: false), toFile: AppUser.ArchiveURL.path)
        
        if isSuccessfullSave {
            os_log("User successfully saved by AppStartController", log:OSLog.default, type: .debug)
        } else {
            os_log("Failed to save user in AppStartController...", log:OSLog.default, type: .error)
        }
    }
}
