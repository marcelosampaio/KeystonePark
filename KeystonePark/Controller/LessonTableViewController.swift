//
//  LessonTableViewController.swift
//  KeystonePark
//
//  Created by Marcelo on 22/10/18.
//  Copyright © 2018 Marcelo. All rights reserved.
//

import UIKit
import CoreData

class LessonTableViewController: UITableViewController {
    
    // MARK: - Properties
    public var moc : NSManagedObjectContext? {
        didSet {
            if let moc = moc {
                lessonService = LessonService(moc: moc)
            }
        }
    }
    private var studentList = [Student]()
    private var lessonService : LessonService?
    private var studentToUpdate : Student?
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAppData()
        
    }
    
    // MARK: - Application Data Source
    private func loadAppData() {
        if let students = lessonService?.getAllStudents() {
            studentList = students
            tableView.reloadData()
        }
    }
    

    // MARK: - TableView DataSource and Delegatte
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        cell.textLabel?.text = studentList[indexPath.row].name
        cell.detailTextLabel?.text = studentList[indexPath.row].lesson?.type

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentToUpdate = studentList[indexPath.row]
        present(alertController(actionType: "update"), animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            lessonService?.delete(student: studentList[indexPath.row])
            studentList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - UI Actions
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        present(alertController(actionType: "Add"), animated: true, completion: nil)
    }
    
    // MARK: - Alert Helper
    private func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Keystone Park Lesson", message: "Student Info", preferredStyle: .alert)
        
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "Name"
            textField.text = self?.studentToUpdate == nil ? "" : self?.studentToUpdate?.name
            
        }
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "Lesson Type: Ski or Snowboard"
            textField.text = self?.studentToUpdate == nil ? "" : self?.studentToUpdate?.lesson?.type
            
        }
        let defaultAction = UIAlertAction(title: actionType, style: .default) { (action) in
            
            
            // check if data entry is ok
            var studentName = String()
            var lesson = String()
            
            if alertController.textFields?[0].text != nil {
                studentName = alertController.textFields?[0].text ?? ""
            }
            if alertController.textFields?[1].text != nil {
                lesson = alertController.textFields?[1].text ?? ""
            }

            if actionType.caseInsensitiveCompare("add") == .orderedSame {
                if let lessonType = LessonType(rawValue: lesson.lowercased()) {
                    self.lessonService?.addStudent(name: studentName, type: lessonType, completion: { (success, students) in
                        // completion
                        if success {
                            self.studentList = students
                            
                        }
                        })
                    }
            }else{
                // update the row
                let studentToUpdate = self.studentToUpdate
                if !studentName.isEmpty && !lesson.isEmpty {
                    self.lessonService?.update(currentStudent: studentToUpdate!, name: studentName, lesson: lesson)
                    self.studentToUpdate = nil
                    
                }
                
                DispatchQueue.main.async {
                    self.loadAppData()
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        return alertController
        
    }
}
