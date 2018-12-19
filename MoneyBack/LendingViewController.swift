//
//  LendingViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 23/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log
import MessageUI

class LendingViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate, UITabBarDelegate, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var lendingTitle: UITextField!
    @IBOutlet weak var lendingAmount: UITextField!
    @IBOutlet weak var lendingContact: UITextField!
    @IBOutlet weak var lendingSaveButton: UIBarButtonItem!
    @IBOutlet weak var lendingDate: UIDatePicker!
    @IBOutlet weak var lendingDateLabel: UILabel!
    @IBOutlet weak var lendingEmail: UITextField!
    @IBOutlet weak var lendingPhone: UITextField!
    
    //TabBar part
    @IBOutlet weak var lendingDeleteBtn: UITabBarItem!
    @IBOutlet weak var lendingTabBar: UITabBar!
    @IBOutlet weak var lendingMsgBtn: UITabBarItem!
    @IBOutlet weak var lendingEmailBtn: UITabBarItem!
    
    /*
     This value is either passed by `HomePageViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new lending.
     */
    
    var lending: Lending?
    var oldAmount = 0
    
    let characterSet = NSCharacterSet(charactersIn: " €")
    let alertTel = "le numéro de téléphone"
    let alertEmail = "l'email"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init tabbar and its buttons
        lendingTabBar.delegate = self
        lendingDeleteBtn.image = UIImage(named: "trash")?.withRenderingMode(.alwaysOriginal)
        lendingMsgBtn.image = UIImage(named: "message")?.withRenderingMode(.alwaysOriginal)
        lendingEmailBtn.image = UIImage(named: "email")?.withRenderingMode(.alwaysOriginal)
        
        
        if (Locale.current.regionCode == "FR") {
            lendingDate.locale = Locale.init(identifier: "fr_FR")
        } else {
            lendingDate.locale = Locale.init(identifier: "en")
        }
        
        lendingTabBar.isHidden = true
        // Handle the text field's user input through delegate callbacks.
        lendingTitle.delegate = self
        lendingTitle.tag = 0
        lendingAmount.delegate = self
        lendingAmount.tag = 1
        lendingContact.delegate = self
        lendingContact.tag = 2
        lendingDateLabel.text = "Date du prêt :"
        lendingEmail.delegate = self
        lendingEmail.tag = 3
        lendingPhone.delegate = self
        lendingPhone.tag = 4
    
        // Set up views if editing an existing Lending.
        if let lending = lending {
            lendingTabBar.isHidden = false
            
            let emptyPhone = lending.phone.isEmpty
            let emptyEmail = lending.email.isEmpty
            
            if !emptyPhone || !emptyEmail {
                //activateReminderBtn(true)
            }
            
            self.title = "Prêt : " + lending.title
            
            lendingTitle.text = lending.title
            lendingAmount.text = String(lending.amount) + " €"
            lendingContact.text = lending.contact
            lendingDate.date = lending.lendingDate
            oldAmount = lending.amount
            lendingEmail.text = lending.email
            lendingPhone.text = lending.phone
        }
        
        // Enable the save button only if the text fields have valid values.
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        let amountEmpty = lendingAmount.text?.isEmpty
        if amountEmpty != nil && !amountEmpty! {
            if let test = lendingAmount.text?.rangeOfCharacter(from: characterSet as CharacterSet) {
            } else {
                let originalText = lendingAmount.text
                lendingAmount.text = originalText! + " €"
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the save button while editing
        if lendingAmount.isEditing {
            lendingAmount.text = lendingAmount.text?.replacingOccurrences(of: " €", with: "")
        }
        updateSaveButtonState()
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
        guard let amount = Int(lendingAmount.text?.replacingOccurrences(of: " €", with: "") ?? "0") else {
        //guard let amount = Int(lendingAmount.text ?? "0") else {
            os_log("It seems that the amount entered is incorrect", log: OSLog.default, type: .debug)
            return
        }
        let contact = lendingContact.text ?? ""
        let date = lendingDate.date
        
        let email = lendingEmail.text ?? ""
        let phone = lendingPhone.text ?? ""
        
        // Set the lending to be passed to HomePageViewController after the unwind segue.
        lending = Lending(amount: amount, oldAmount: oldAmount, title: title, contact: contact, lendingDate: date, email: email, phone: phone)
        
    }
    
    //MARK: Tabbar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch(item) {
        case lendingMsgBtn:
            let emptyPhone = lending?.phone.isEmpty
            if emptyPhone != nil && !emptyPhone! {
                sendMessage()
            }
            else {
                alertUser(alertTel)
            }
        
        case lendingEmailBtn:
            let emptyEmail = lending?.email.isEmpty
            if emptyEmail != nil && !emptyEmail! {
                print("Email")
                sendEmail()
            } else {
                alertUser(alertEmail)
            }
        
        default:
            os_log("used button has not yet an action within the app", log: OSLog.default, type: .debug)
        }
    }
    
    //MARK: Private Methods
    func updateSaveButtonState() {
        // Disable the save button if the text field is empty.
        let title = lendingTitle.text ?? ""
        let amount = lendingAmount.text ?? ""
        let contact = lendingContact.text ?? ""
        
        lendingSaveButton.isEnabled = !title.isEmpty && !amount.isEmpty && !contact.isEmpty
    }
    
    //@IBAction func lendingReminderBtn(sender: UIButton) {
    func sendMessage() {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        
        // Display the fields of the interface
        let amount = lendingAmount.text ?? "0"
        let title = lendingTitle.text ?? ""
        let msg = "Bonjour, petit rappel pour les " + amount + " que je t'ai prêté le " + formatDateToString(date: lendingDate.date) + " , pour le motif : " + title + ". Peux-tu mettre un rappel pour y penser stp? Merci."
        controller.body = msg
        controller.recipients = [lendingPhone.text ?? "0666650933"]
        
        if (MFMessageComposeViewController.canSendText()) {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue:
            print("message cancelled")
            
        case MessageComposeResult.failed.rawValue:
            print("message failed")
            
        case MessageComposeResult.sent.rawValue:
            print("message sent")
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendEmail() {
        
        let mail = MFMailComposeViewController()
        let amount = lendingAmount.text ?? "0"
        let title = lendingTitle.text ?? ""
        
        mail.mailComposeDelegate = self
        mail.setToRecipients([lendingEmail.text ?? "alex93200@hotmail.com"])
        
        let msg = "<p>Bonjour, petit rappel pour les " + amount + " que je t'ai prêté le " + formatDateToString(date: lendingDate.date) + " , pour le motif : " + title + ".</p><p>Peux-tu mettre un rappel pour y penser stp? Merci.<p>"
        
        mail.setMessageBody(msg, isHTML: true)
        mail.setSubject("Prêt d'argent")
        
        if MFMailComposeViewController.canSendMail() {
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue:
            print("Email cancelled")
            
        case MessageComposeResult.failed.rawValue:
            print("Email failed")
            
        case MessageComposeResult.sent.rawValue:
            print("Email sent")
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        
    }

    
    /*func formatStringToDate(date: String) -> Date {
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
    }*/
    
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

    func alertUser(_ msg: String) {
        let alert = UIAlertController(title: "Donnée manquante", message: "Vous devez renseigner " + msg + " pour utiliser la fonctionnalité.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Compris", style: .default, handler: nil))
        //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}
