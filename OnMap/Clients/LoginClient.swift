//
//  LoginClient.swift
//  OnMap
//
//  Created by Varosyan, Anna on 27.08.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin
import FBSDKCoreKit


class LoginClient {
    
    
    //MARK: Singleton
    static let shared = LoginClient()
    
    //MARK: Constants
    let session = URLSession.shared
    
    //MARK: Properties
    var udacitySessionID: String? = nil
    var udacityAccountKey: String? = nil
    var udacityFirstName: String? = nil
    var udacityLastName: String? = nil

    //MARK: Functions
    
    public func login(email: String, password: String, completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
        let requestBody = LoginRequest.get(email, password)
        let request = getLoginRequest(withBody: requestBody)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            self.handleLoginTaskCompletion(data, response, error, completion)
        }
        task.resume()
    }
    
    func loginWithFacebook(completion: (_ success: Bool, _ displayError: String?) -> Void) {
        guard (AccessToken.current?.tokenString) != nil else {
            completion(false, ErrorType.no_FB_access_token)
            return
        }
        udacityAccountKey = AccessToken.current?.userID
        udacityFirstName = "Facebook"
        udacityLastName = "Facebook"
        // all fine
        completion(true, nil)
    }
    
    func logout(completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
        
        //log out of Facebook if necessary
       if (AccessToken.current != nil) {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
       
        var request = URLRequest(url: URL(string: URL_ONMAP.session)!)
        request.httpMethod = "DELETE"
        
        //add anti-XSRF cookie that Udacity server knows that it is the logged in user
        if let xsrfCookie = Utils.getCookie(withKey: "XSRF-TOKEN") {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: RequestKey.xxsrfToken)
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if let responseError = ResponseHandler(data, response, error).getResponseError() {
                completion(false, responseError)
                return
            }
            // everything is finee, continue
            completion(true, nil)
        }
        task.resume()
    }
    
    private func getLoginRequest<T: Encodable>(withBody body: T) -> URLRequest {
        var request = URLRequest(url: URL(string: URL_ONMAP.session)!)
        request.httpMethod = "POST"
        request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.accept)
        request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.contentType)
        request.httpBody = JSONParser.encode(body).data(using: String.Encoding.utf8)
       
        return request
    }
    
    private func handleLoginTaskCompletion(_ data: Data?,
                                           _ response: URLResponse?,
                                           _ error: Error?,
                                           _ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
       
        let responseHandler = ResponseHandler(data, response, error)
        
        if let responseError = responseHandler.getResponseError() {
            completion(false, responseError)
            return
        } else {
            // everyting is fine, no error so far
            let subsetResponseData = removeHeaderFromResponse(data!)
            
            guard let response:LoginResponse = JSONParser.decode(subsetResponseData) else {
                completion(false, ErrorType.json_decoding)
                return
            }
            
            udacityAccountKey = response.account.key
            udacitySessionID = response.session.id
            
            getUserDetails(completion)
        }
     
    }
    
    //Remove extra 5 header symbols from Udacity response
    private func removeHeaderFromResponse(_ data: Data) -> Data {
        let responseHeaderLength = 5
        return data.subdata(in: responseHeaderLength..<data.count)
    }
    
    private func getUserDetails(_ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void)
    {
        let request = URLRequest(url: URL(string: URL_ONMAP.users + udacityAccountKey!)!)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if let responseError = ResponseHandler(data, response, error).getResponseError() {
                completion(false, responseError)
                return
            }
            let subsetResponseData = self.removeHeaderFromResponse(data!)
            // Doesn't make sense to use Codable because the reponse data contains too many fields
            guard let responseDictionary = JSONParser.deserialize(subsetResponseData) as? [String: AnyObject] else {
                completion(false, ErrorType.json_deserializing)
                return
            }
                  
            guard let firstName = responseDictionary[UdacityResponseKey.firstName] as? String else {
                completion(false, ErrorType.unexpected)
                return
            }
            
            guard let lastName = responseDictionary[UdacityResponseKey.lastName] as? String else {
                completion(false, ErrorType.unexpected)
                return
            }
            
            self.udacityFirstName = firstName
            self.udacityLastName = lastName
            
            completion(true, nil)
        }
        task.resume()
    }
}

extension LoginClient {

    //MARK: Private - Request structs
    struct UdacityResponseKey {
        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
    
    private struct LoginRequest: Codable {
        private let udacity : Udacity
        
        private struct Udacity : Codable {
            let username: String
            let password: String
        }
        
        static func get(_ username: String, _ password: String) -> LoginRequest {
            return LoginRequest(udacity: Udacity(username: username, password: password))
        }
    }
    
    private struct FacebookLoginRequest: Codable {
        private let facebook_mobile : FacebookMobile
        
        private struct FacebookMobile : Codable {
            let access_token: String
        }
        
        static func get(_ accessToken: String) -> FacebookLoginRequest {
            return FacebookLoginRequest(facebook_mobile: FacebookMobile(access_token: accessToken))
        }
    }
    
    //MARK: Private - Response structs
    private struct LoginResponse: Codable {
        
        let account: Account
        let session: Session
        
        struct Account: Codable {
            let registered: Bool
            let key: String
        }
        
        struct Session: Codable {
            let id: String
            let expiration: String
        }
    }
}
