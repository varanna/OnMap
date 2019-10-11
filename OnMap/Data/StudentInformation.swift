//
//  Student.swift
//  OnMap
//
//  Created by Varosyan, Anna on 02.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

struct StudentInformation : Codable {
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
    
   /* init(_ studentRecordResponse: ParseClient.StudentRecordResponse) {
        createdAt = studentRecordResponse.createdAt!
        firstName = studentRecordResponse.firstName!
        lastName = studentRecordResponse.lastName!
        latitude = studentRecordResponse.latitude!
        longitude = studentRecordResponse.longitude!
        mapString = studentRecordResponse.mapString!
        mediaURL = studentRecordResponse.mediaURL!
        objectId = studentRecordResponse.objectId!
        uniqueKey = studentRecordResponse.uniqueKey!
        updatedAt = studentRecordResponse.updatedAt!
    }
 */
}
