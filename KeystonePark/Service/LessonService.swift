//
//  LessonService.swift
//  KeystonePark
//
//  Created by Marcelo on 22/10/18.
//  Copyright © 2018 Marcelo. All rights reserved.
//

import Foundation
import CoreData


enum LessonType : String {
    case ski
    case snowboard
}

typealias StudentHandler = (Bool, [Student]) -> ()



class LessonService {
    
    private let moc : NSManagedObjectContext
    private var students = [Student]()  // NSMAnagedObject of core data
    
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    // MARK: - Public Functions
    public func addStudent(name: String, type: LessonType, completion: StudentHandler) {
        
        let student = Student(context: moc)
        student.name = name
        
        if let lesson = lessonExists(type) {
            register(student, lesson: lesson)
            students.append(student)
            
            completion(true, students)
            
        }
        save()
        
    }
    
    public func getAllStudents() -> [Student]? {
        
        let sortByLesson = NSSortDescriptor(key: "lesson.type", ascending: true)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortByLesson, sortByName]
        
        
        let request : NSFetchRequest<Student> = Student.fetchRequest()
        request.sortDescriptors = sortDescriptors
        
        do {
            students = try moc.fetch(request)
            return students
        } catch let error as NSError {
            print("Error getting students: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func update(currentStudent: Student, name: String, lesson: String) {
        // chck if student lesson == new lesson type
        if currentStudent.lesson?.type?.caseInsensitiveCompare(lesson) == .orderedSame {
            let lesson = currentStudent.lesson
            let studentsList = Array(lesson?.students?.mutableCopy() as! NSMutableSet) as! [Student]
            
            if let index = studentsList.index(where: { $0 == currentStudent }) {
                studentsList[index].name = name
                lesson?.students = NSSet(array: studentsList)
            }
        }else{
            if let lesson = lessonExists(LessonType(rawValue: lesson)!) {
                lesson.removeFromStudents(currentStudent)
                currentStudent.name = name
                register(currentStudent, lesson: lesson)
            }
        }
        save()
    }
    
    // MARK: - Private Functions
    private func lessonExists(_ type: LessonType) -> Lesson? {
        
        let request : NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "type = %@", type.rawValue)
        var lesson : Lesson?
        do {
            let result = try moc.fetch(request)
            lesson = result.isEmpty ? addNewLesson(type: type) : result.first
        }
        catch let error as NSError  {
            print("Error getting lesson: \(error.localizedDescription)")
        }
        
        return lesson
        
    }
    
    private func addNewLesson(type: LessonType) -> Lesson {
        let lesson = Lesson(context: moc)
        lesson.type = type.rawValue
        return lesson
    }
    
    private func register(_ student: Student, lesson: Lesson) {
        student.lesson = lesson
    }
    
    private func save() {
        do {
            try moc.save()
        }
        catch let error as NSError {
            print("Error saving student: \(error.localizedDescription)")
        }
    }
    
}
