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
    

    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var onboardingContainer: UIView!
    
    @IBAction func skipOnboarding(_ sender: UIButton) {
        sender.removeFromSuperview()
        onboardingContainer.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipBtn.isEnabled = false
        skipBtn.isHidden = true
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
            os_log("Going to the login page.", log: OSLog.default, type: .debug)
            
        case "displayOnboarding":
            os_log("Displaying onboarding screen.", log: OSLog.default, type: .debug)
            
            guard let onboardingController = segue.destination as? OnboardingViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            onboardingController.skipBtn = skipBtn
            
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    } 
}
