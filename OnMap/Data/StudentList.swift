//
//  StudentList.swift
//  OnMap
//
//  Created by Varosyan, Anna on 02.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

class StudentList {
    static let instance = StudentList()
    
    private var currentList = [StudentInformation]()
    
    func set(_ records: [StudentInformation]) {
        currentList = records
    }
    
    func getAll() -> [StudentInformation] {
        return currentList
    }
    
    func get(fromIndex index: Int) -> StudentInformation? {
        if (index >= currentList.count) {
            print("Student list index is out of bounds.")
            return nil
        }
        return currentList[index]
    }
}
