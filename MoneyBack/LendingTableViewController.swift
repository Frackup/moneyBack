//
//  LendingTableViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 26/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class LendingTableViewController: UITableViewController {
    
    //MARK: Properties
    var lendingsList = [Lending]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lendingsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LendingTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LendingTableViewCell else {
            fatalError("The dequeued cell is not an instance of LendingTableViewCell.")
        }

        // Fetches the appropriate lending for the data source layout.
        let lending = lendingsList[indexPath.row]
        
        cell.lendingTitle.text = lending.title
        cell.lendingAmount.text = String(lending.amount) + " €"
        cell.lendingDate.text = lending.lendingDate
        cell.lendingContact.text = "à " + lending.contact

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            lendingsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveLendings()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    //MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowLendingDetail":
            /*guard let navVC = segue.destination as? UINavigationController else {
                fatalError("It seems that your Lendings list table is not implementing Navigation controller")
            }
            
            guard let lendingDetailViewController = navVC.viewControllers.first as? LendingViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }*/
            
            guard let lendingDetailViewController = segue.destination as? LendingViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedLendingCell = sender as? LendingTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedLendingCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedLending = lendingsList[indexPath.row]
            lendingDetailViewController.lending = selectedLending
            
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    }
    
    //MARK: Actions
    /*@IBAction func unwindToLendingList(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UITableViewController) {
        if let sourceViewController = unwindSegue.source as? LendingViewController, let lending = sourceViewController.lending {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing lending.
                lendingsList[selectedIndexPath.row] = lending
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                fatalError("Erreur au niveau de la mise à jour du tableau")
            }
            
            // Save tne meals.
            saveLendings()
        }
    }*/
    
    @IBAction func unwindToHomePage(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LendingViewController, let lending = sourceViewController.lending {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing lending.
                lendingsList[selectedIndexPath.row] = lending
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                os_log("coucou je suis dans le else", log: OSLog.default, type: .debug)
                // Noprmalement pas de else ici
                
                // Add a new meal
                /*let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)*/
            }
            
            // Save tne meals.
            saveLendings()
        }
    }
    
    //MARK: Private Methods
    func saveLendings() {
        let isSuccessfullSave = NSKeyedArchiver.archiveRootObject(lendingsList, toFile: Lending.ArchiveURL.path)
        
        if isSuccessfullSave {
            os_log("Lendings successfully saved", log:OSLog.default, type: .debug)
        } else {
            os_log("Failed to save lendings...", log:OSLog.default, type: .error)
        }
    }
}
