//
//  SettingsViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 12/12/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveSettingsBtnPressed))
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private Methods
    /*func createSettingsBtn() -> UIButton {
        //create a new button
        let button = UIButton(type: .custom)
        //set image for button
        //button.setImage(UIImage(named: "settings"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(saveSettingsBtnPressed), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return button
    }*/
    
    @objc func saveSettingsBtnPressed() {
        
        print("Settings saved")
    }

}
