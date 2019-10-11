//
//  Utils.swift
//  OnMap
//
//  Created by Varosyan, Anna on 28.08.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    static func showErrorAlert(_ controller: UIViewController, _ message: String?) {
        guard message != nil else {
            print("showErrorAlert(): No message to display.")
            return
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func getCookie(withKey key: String) -> HTTPCookie? {
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == key {
                return cookie
            }
        }
        return nil
    }
}
