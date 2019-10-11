//
//  ResponseHandler.swift
//  OnMap
//
//  Created by Varosyan, Anna on 02.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

class ResponseHandler {
    
    let data: Data?
    let response: URLResponse?
    let error: Error?
    
    init(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    // MARK: Public
    public func getResponseError() -> String? {
        
        if let errorString = checkError() {
            return errorString
        }
       
        // there was no error before, convert to HTTPPURLResponse to check the status code
        //get http response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Expected HTTPURLResponse but was \(type(of: response))")
            return ErrorType.no_http_response
        }
        let statusCode = httpResponse.statusCode
        
        if let statusCodeCheckString = checkHttpStatusCode(statusCode) {
            return statusCodeCheckString
        }

        //everything is fine till now, but now check that any data was returned
        if data == nil {
            print("No data was returned in the response.")
            return ErrorType.empty_response_data
        }
        
        return nil
    }
    
    // MARK: Private functions
    private func checkError() -> String? {
        //check no error was returned
        if error != nil {
            print(error!.localizedDescription)
            if error!.localizedDescription == ErrorType.system_offline {
                return ErrorType.system_offline
            } else {
                return ErrorType.unexpected
            }
        }
        return nil
    }
    
    private func checkHttpStatusCode(_ statusCode: Int) -> String? {
        let invalidCredentialsStatusCode = 403
        //check http response status code was 2xx
        if (statusCode > 200)  {
            print("There was a problem with the request. Status code is \(statusCode)")
            
            //if status code is 403, assume credentials were invalid
            return statusCode == invalidCredentialsStatusCode ? ErrorType.incorrect_credentials : ErrorType.unexpected
        }
        return nil
    }
}
