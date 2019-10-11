//
//  StudentsListController.swift
//  OnMap
//
//  Created by Varosyan, Anna on 02.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import UIKit

class StudentsListController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //MARK: Constants
    let cellIdentifier = "StudentTableCell"
    
    //MARK: Properties
    let spinner = ProgressSpinner()
   
    //MARK: Outlets
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var studentTableView: UITableView!
    
    //MARK: UIViewController overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (ParseClient.shared.needsRefresh) {
            refresh()
        }
        displayAllStudents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // assign delegate
        studentTableView.delegate = self
        studentTableView.dataSource = self
    }
    
    @IBAction func refresh() {
        showRefreshState(true)
        // get the students list and show in table
        ParseClient.shared.getStudentsList { (successful, error) in
            DispatchQueue.main.async {
                self.showRefreshState(false)
                if successful {
                    self.displayAllStudents()
                } else {
                    Utils.showErrorAlert(self, error)
                }
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        ParseClient.shared.needsRefresh = true
        spinner.show(self)
        LoginClient.shared.logout(completion: {(successful, displayError) in
            DispatchQueue.main.async {
                self.spinner.hide()
                if (successful) {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    Utils.showErrorAlert(self, displayError)
                }
            }
        })
    }
    
    // MARK: private functions
    private func showRefreshState(_ refresh: Bool) {
        refreshButton.isEnabled = !refresh
        if (refresh) {
            spinner.show(self)
        } else {
            spinner.hide()
        }
    }
    
    func displayAllStudents() {
        studentTableView.reloadData()
    }

    //MARK: UITableViewDataSource implementation
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentList.instance.getAll().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let student = StudentList.instance.get(fromIndex: indexPath.row) else {
            print ("Student was not found.")
            return cell
        }
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        return cell
    }
    
    //MARK: UITableViewDelegate implementation
    
    //navigate to student's media URL on row tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let student = StudentList.instance.get(fromIndex: indexPath.row) else {
            print ("Student was not found.")
            return
        }
        // open the URL of the student: Note that it should be in the complete URL format
        let url = URL(string: student.mediaURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
