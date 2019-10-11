//
//  LoginViewController.swift
//  OnMap
//
//  Created by Varosyan, Anna on 26.08.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var textPasswordField: UITextField!
    @IBOutlet weak var textEmailField: UITextField!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var btnSignUp: UILabel!
    @IBOutlet weak var labelSignUp: UILabel!
    @IBOutlet weak var btnLoginFB: UIButton!
    // MARK: Constants
    
    let loginSegue = "LoginSegue"
    var fbLoginSuccess = false
    
    // MARK: Properties
    let spinner = ProgressSpinner()
    var activeField: UITextField?
    
    //MARK:  View overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateGestureForSignUp()
        // assign delegates
        textEmailField.delegate = self
        textPasswordField.delegate = self
    }
    
    // solution from https://stackoverflow.com/questions/36238925/segue-wont-trigger-after-facebook-login-with-swift
    override func viewDidAppear(_ animated: Bool) {
        if (fbLoginSuccess){
            fbLoginSuccess = false
            performSegue(withIdentifier: self.loginSegue, sender: nil)
        }
    }
    
    //MARK: IBActions
    @IBAction func loginUdacity(_ sender: Any) {
        if checkLoginFieldsAreReady() {
          spinner.show(self)
          LoginClient.shared.login(email: textEmailField.text!, password: textPasswordField.text!,
                                   completion: completeLogin(_:_:))
        } else {
            Utils.showErrorAlert(self, ErrorType.empty_credentials)
        }
    }
    
    @IBAction func loginFacebook(_ sender: Any) {
            spinner.show(self)
            LoginManager().logIn(permissions: [ .publicProfile ], viewController: self) { loginResult in
            
                switch loginResult {
                case .success:
                    print("Congrats! Facebook login was successful.")
                    LoginClient.shared.loginWithFacebook(completion: self.completeLogin(_:_:))
                    self.fbLoginSuccess = true
                case .cancelled:
                    print("Facebook login was cancelled by the user.")
                    DispatchQueue.main.async {
                        self.spinner.hide()
                    }
                case .failed(let error):
                    print("Error appeared while trying to log in(Facebook): \(error)")
                    DispatchQueue.main.async {
                        self.spinner.hide()
                    }
                }
            }
    }

    //MARK: Private functions
    @objc private func redirectToUdacitySignUp() {
        let url = URL(string: URL_ONMAP.signUpUdacityURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func checkLoginFieldsAreReady()  -> Bool {
        return !(textPasswordField.text!.isEmpty || textEmailField.text!.isEmpty)
           
    }

    private func activateGestureForSignUp () {
        labelSignUp.isUserInteractionEnabled = true
        labelSignUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redirectToUdacitySignUp)))
    }
    
    private func completeLogin(_ successful: Bool, _ displayError: String?) {
        DispatchQueue.main.async {
            if (successful) {
                if ( !self.fbLoginSuccess ) {
                    self.performSegue(withIdentifier: self.loginSegue, sender: nil)
                }
            } else {
                Utils.showErrorAlert(self, displayError)
            }
            
            self.spinner.hide()
        }
    }
}

// Solution from https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
extension LoginViewController : UITextFieldDelegate {
    // MARK: KEYBOARD controlling functions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
     @objc  func keyboardWillShow(_ notification: Notification) {
        containerScrollView.isScrollEnabled = true
        let keyboardHeight = getKeyboardHeight(notification)
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        
        containerScrollView.contentInset = contentInsets
        containerScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = view.frame
        aRect.size.height -= keyboardHeight
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)) {
                containerScrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
     @objc func keyboardWillHide(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardHeight, right: 0.0)
        containerScrollView.contentInset = contentInsets
        containerScrollView.scrollIndicatorInsets = contentInsets
        containerScrollView.isScrollEnabled = false
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
