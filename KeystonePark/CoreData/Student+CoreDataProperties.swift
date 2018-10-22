//
//  Student+CoreDataProperties.swift
//  KeystonePark
//
//  Created by Marcelo on 22/10/18.
//  Copyright © 2018 Marcelo. All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String?
    @NSManaged public var lesson: Lesson?

}
