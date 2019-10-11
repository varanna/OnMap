//
//  Constants.swift
//  OnMap
//
//  Created by Varosyan, Anna on 27.08.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

struct ErrorType {
    static let unexpected = "An unexpected error occurred."
    static let incorrect_credentials = "Incorrect email or password."
    static let empty_credentials = "Empty username or password."
    static let no_FB_access_token = "The Facebook access token is not set."
    static let system_offline = "The Internet connection appears to be offline."
    static let empty_response_data = "No data was returned in the URL response."
    static let no_http_response = "Cannot convert URL response to HTTPURLResponse"
    static let json_encoding = "Problems/errors appeared while encoding the given object to JSON"
    static let json_decoding = "Problems/errors appeared while decoding the given data to type"
    static let json_deserializing = "Problems/errors appeared while deserializing the given data to JSON"
    
}

struct URL_ONMAP {
    static let signUpUdacityURL = "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated"
    static let session = "https://onthemap-api.udacity.com/v1/session"
    static let users = "https://onthemap-api.udacity.com/v1/users/"
    static let studentLocation = "https://onthemap-api.udacity.com/v1/StudentLocation"
}

struct RequestKey {
    static let accept = "Accept";
    static let contentType = "Content-Type";
    static let xxsrfToken = "X-XSRF-TOKEN";
}

struct RequestValue {
    static let jsonType = "application/json";
}


var dictParseRequestInfoKeys: [String: [String]] =
    [ "applicationID" : ["X-Parse-Application-Id", "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"],
        "apiKey" : ["X-Parse-REST-API-Key", "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" ]
]
