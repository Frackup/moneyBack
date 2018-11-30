//
//  LendingViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 23/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class LendingViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var lendingTitle: UITextField!
    @IBOutlet weak var lendingAmount: UITextField!
    @IBOutlet weak var lendingContact: UITextField!
    @IBOutlet weak var lendingSaveButton: UIBarButtonItem!
    @IBOutlet weak var lendingDate: UIDatePicker!
    @IBOutlet weak var lendingDateLabel: UILabel!
    
    /*
     This value is either passed by `HomePageViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new lending.
     */
    
    var lending: Lending?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field's user input through delegate callbacks.
        lendingTitle.delegate = self
        lendingAmount.delegate = self
        lendingContact.delegate = self
        lendingDateLabel.text = "Date du prêt :"
        //lendingDate.delegate = self
    
        // Set up views if editing an existing Lending.
        if let lending = lending {
            lendingTitle.text = lending.title
            lendingAmount.text = String(lending.amount)
            lendingContact.text = lending.contact
            lendingDate.date = formatStringToDate(date: lending.lendingDate)
        }
        
        // Enable the save button only if the text fields have valid values.
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the save button while editing
        lendingSaveButton.isEnabled = false
    }

    // MARK: - Navigation
    @IBAction func lendingCancelButton(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways
        let isPresentingInAddLendingMode = presentingViewController is UINavigationController
        if isPresentingInAddLendingMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("the LendingViewController is not inside a navigation controller.")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the saved button is pressed.
        guard let button = sender as? UIBarButtonItem, button === lendingSaveButton else {
            os_log("The saved button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let title = lendingTitle.text ?? ""
        guard let amount = Int(lendingAmount.text ?? "0") else {
            os_log("It seems that the amount entered is incorrect", log: OSLog.default, type: .debug)
            return
        }
        let contact = lendingContact.text ?? ""
        //let date = lendingDate.text ?? ""
        let date = formatDateToString(date: lendingDate.date)
        
        // Set the lending to be passed to HomePageViewController after the unwind segue.
        lending = Lending(amount: amount, title: title, contact: contact, lendingDate: date)
        
    }
    
    //MARK: Private Methods
    func updateSaveButtonState() {
        // Disable the save button if the text field is empty.
        let title = lendingTitle.text ?? ""
        let amount = lendingAmount.text ?? ""
        let contact = lendingContact.text ?? ""
        let date = formatDateToString(date: lendingDate.date)
        
        lendingSaveButton.isEnabled = !title.isEmpty && !amount.isEmpty && !contact.isEmpty && !date.isEmpty
    }
    
    /*@objc func datePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        
        lendingDate.text = formatter.string(from: sender.date)
    }*/
    
    func formatStringToDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let dateSTR = dateFormatter.date(from: date) else {
            os_log("The format define is not inline with the format of the string", log: OSLog.default, type: .debug)
            
            // As we don't have a valid date, we set the current date instead
            let curDate = Date()
            //let result = dateFormatter.string(from: curDate)
            return curDate
        }
        return dateSTR
    }
    
    func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateSTR = dateFormatter.string(from: date)
        if !dateSTR.isEmpty {
            return dateSTR
        } else {
            os_log("The format define is not inline with the format of the string", log: OSLog.default, type: .debug)
            
            // As we don't have a valid date, we set the current date instead
            let curDate = Date()
            let result = dateFormatter.string(from: curDate)
            return result
        }
    }

}
