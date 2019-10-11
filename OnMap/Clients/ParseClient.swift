//
//  ParseClient.swift
//  OnMap
//
//  Created by Varosyan, Anna on 02.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

class ParseClient {
    //MARK: Singleton
    static let shared = ParseClient()
    
    //MARK: Properties
    let session = URLSession.shared
    var needsRefresh = true
    var loggedInStudentRecordID: String? = nil
    
    //MARK: Public Functions
    public func getStudentsList(_ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
        let getLast100Query = "limit=100&order=-updatedAt"
        let urlString = URL_ONMAP.studentLocation + "?\(getLast100Query)"
        let request = getParseRequest(urlString)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            self.needsRefresh = false
            
            if let responseError = ResponseHandler(data, response, error).getResponseError() {
                completion(false, responseError)
                return
            }
            
            guard let response:StudentListResponse = JSONParser.decode(data!) else {
                completion(false, ErrorType.json_decoding)
                return
            }
            
            // all is fine, complete the results
            StudentList.instance.set(response.results)
            completion(true, nil)
        }
        task.resume()
    }
    
    public func setStudentLocation(_ mapString: String,
                          _ latitude: Double,
                          _ longitude: Double,
                          _ mediaUrl: String,
                          _ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
        
        
        let settingURL = (loggedInStudentRecordID == nil ? URL_ONMAP.studentLocation : URL_ONMAP.studentLocation + "/" + loggedInStudentRecordID!)
        let httpMethod = (loggedInStudentRecordID == nil ? "POST" :"PUT" )
        let newStudentRequest = StudentInfoRequest(mapString, mediaUrl, latitude, longitude)
       
        var request: URLRequest
        request = getParseRequest(settingURL)
        request.httpMethod = httpMethod
        request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.contentType)
        request.httpBody = JSONParser.encode(newStudentRequest).data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            // new student is added, needs to be refreshed
            self.needsRefresh = true
            //check if any error happened
            if let responseError = ResponseHandler(data, response, error).getResponseError() {
                completion(false, responseError)
                return
            }
            // everything is fine
            completion(true, nil)
        }
        task.resume()
    }
    
    //MARK: Private Functions
    private func getParseRequest(_ urlString: String) -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        for key in dictParseRequestInfoKeys.keys {
            request.addValue(dictParseRequestInfoKeys[key]![1], forHTTPHeaderField: dictParseRequestInfoKeys[key]![0])
        }
        return request
    }
    
    //MARK: Request struct
    private struct StudentInfoRequest: Codable {
        let uniqueKey: String
        let firstName: String
        let lastName: String
        let mapString: String
        let mediaURL: String
        let latitude: Double
        let longitude: Double
        
        init(_ mapString: String, _ mediaURL: String, _ latitude: Double, _ longitude: Double) {
            self.uniqueKey = LoginClient.shared.udacityAccountKey!
            self.firstName = LoginClient.shared.udacityFirstName!
            self.lastName = LoginClient.shared.udacityLastName!
            self.mapString = mapString
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    //MARK: Response list struct
    private struct StudentListResponse : Codable {
        var results: [StudentInformation]
    }
}

