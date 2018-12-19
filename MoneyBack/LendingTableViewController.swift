//
//  LendingTableViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 26/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class LendingTableViewController: UITableViewController, UISearchResultsUpdating {

    //MARK: Properties
    var lendingsList = [Lending]()
    var appUser: AppUser!
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredLendingsList = [Lending]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        
        if let myUser = appUser {
            os_log("User correctly transmitted to LendingListViewController", log: OSLog.default, type: .debug)
        } else {
            fatalError("The user should exist when going to the LendingListCViewController")
        }

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
        return searchController.isActive ? filteredLendingsList.count : lendingsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LendingTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LendingTableViewCell else {
            fatalError("The dequeued cell is not an instance of LendingTableViewCell.")
        }

        // Fetches the appropriate lending for the data source layout.
        let lending = searchController.isActive ? filteredLendingsList[indexPath.row] : lendingsList[indexPath.row]
        
        //let lending = lendingsList[indexPath.row]
        
        cell.lendingTitle.text = lending.title
        cell.lendingAmount.text = String(lending.amount) + " €"
        cell.lendingDate.text = formatDateToString(date: lending.lendingDate)
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
            appUser.totalAmount -= lendingsList[indexPath.row].amount
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
    @IBAction func unwindToLendingsListAdd(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LendingViewController, let lending = sourceViewController.lending {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing lending.
                lendingsList[selectedIndexPath.row] = lending
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                let amountToAdd = lending.amount - lending.oldAmount
                appUser.totalAmount += amountToAdd
                //saveAppUser()
            }
            // Save tne lendings.
            saveLendings()
        }
    }
    
    @IBAction func unwindToLendingsListDelete(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LendingViewController, let lending = sourceViewController.lending {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Delete the row from the data source
                appUser.totalAmount -= lendingsList[selectedIndexPath.row].amount
                lendingsList.remove(at: selectedIndexPath.row)
                tableView.deleteRows(at: [selectedIndexPath], with: .fade)
                saveLendings()
            }
            // Save tne lendings.
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
    
    // These functions will deal with allowing to search within the lendings in the tableView
    func configureSearchController() {
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self as? UISearchBarDelegate
        searchController.searchBar.scopeButtonTitles = ["Date +", "Date -", "Montants +", "Montants -"]
    }
    
    func filterSearchController(_ searchBar: UISearchBar) {
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else {
            return
        }
        
        //let initialList = lendingsList
        let searchText = searchBar.text ?? ""
        
        /*for myLending in lendingsList {
            myLending.lendingDate = myLending.lendingDate.replacingOccurrences(of: "/", with: "")
        }
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"// yyyy-MM-dd"
        
        for myLending in lendingsList {
            let date = dateFormatter.date(from: myLending.lendingDate)
            if let date = date {
                myLending.lendingDate = date
            }
        }*/
        
        switch(scopeString) {
        case "Montants +":
            lendingsList.sort() { $0.amount < $1.amount }
            
        case "Montants -":
            lendingsList.sort() { $0.amount > $1.amount }
            
        case "Date +":
            lendingsList.sort() { $0.lendingDate < $1.lendingDate }
            
        case "Date -":
            lendingsList.sort() { $0.lendingDate > $1.lendingDate }
            
        default:
            os_log("no filter selected", log: OSLog.default, type: .debug)
        }
        
        filteredLendingsList = lendingsList.filter { lending in
            let isMatchingSearchText = lending.title.lowercased().contains(searchText.lowercased()) || searchText.isEmpty
            
            return isMatchingSearchText
        }
        
        tableView.reloadData()
        //lendingsList = initialList
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchController.searchBar)
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
    
    func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if (Locale.current.regionCode == "FR") {
            dateFormatter.dateFormat = "dd/MM/yyyy"
        } else {
            dateFormatter.dateFormat = "MM/dd/yyyy"
        }
        let dateSTR = dateFormatter.string(from: date)
        if !dateSTR.isEmpty {
            return dateSTR
        } else {
            os_log("The format defined is not inline with the format of the string", log: OSLog.default, type: .debug)
            
            // As we don't have a valid date, we set the current date instead
            let curDate = Date()
            let result = dateFormatter.string(from: curDate)
            return result
        }
    }
}

extension LendingTableViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar)
    }
    
}
