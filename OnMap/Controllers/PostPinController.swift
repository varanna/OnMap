//
//  PostPinController.swift
//  OnMap
//
//  Created by Varosyan, Anna on 03.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostPinController: UIViewController {
    //MARK: Constants
    let pinReuseID = "Pin"
    
    //MARK: Properties
    let spinner = ProgressSpinner()
    var mapString = ""
    var coordinate: CLLocationCoordinate2D? = nil
    var activeField: UITextField?
    
    // prepare view to receive keyboard notifications
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var URLText: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var addressStackView: UIStackView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    //MARK: UIViewController overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUIForNewLocation(true)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // assign delegates
        mapView.delegate = self
        addressText.delegate = self
        URLText.delegate = self
    }
    
    //MARK: IBActions
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        prepareUIForNewLocation(false)
        showLocation()
    }

    @IBAction func finish(_ sender: Any) {
        if checkDataIsEntered() {
            spinner.show(self)
            ParseClient.shared.setStudentLocation(mapString,
                                                coordinate!.latitude,
                                                coordinate!.longitude,
                                                URLText.text!) { (successful, displayError) in
                                                    DispatchQueue.main.async {
                                                        self.spinner.hide()
            
                                                        if (successful) {
                                                            self.dismiss(animated: true, completion: nil)
                                                        } else {
                                                            Utils.showErrorAlert(self, displayError)
                                                        }
                                                    }
                                                }
    
        }
    }
    
    private func prepareUIForNewLocation(_ showNewLocation: Bool) {
        finishButton.isHidden = showNewLocation
        mapView.isHidden = showNewLocation
        addressStackView.isHidden = !showNewLocation
    }
    
    private func checkDataIsEntered() -> Bool {
        guard let address = addressText.text else {
            Utils.showErrorAlert(self, "Please enter an address.")
            return false
        }
        if address.isEmpty {
            Utils.showErrorAlert(self, "Please enter an address.")
            return false
        }
        guard let mediaURL = URLText.text else {
            Utils.showErrorAlert(self, "Please enter a URL.")
            return false
        }
        if mediaURL.isEmpty {
            Utils.showErrorAlert(self, "Please enter a URL.")
            return false
        }
         return true
    }
    
    private func showLocation() {
        mapString = addressText.text!
        spinner.show(self)
        searchLocation(mapString) { (coordinate) in
            DispatchQueue.main.async {
                self.spinner.hide()
                
                if coordinate == nil {
                    Utils.showErrorAlert(self, "Could not find the location of \"\(self.mapString)\".")
                } else {
                    self.coordinate = coordinate
                    //navigate to map location
                    self.mapView.setCenter(coordinate!, animated: false)
                    
                    //add pin
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate!
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        
    }
    
    private func searchLocation(_ searchString: String, _ findCompletion: @escaping (_ coordinate: CLLocationCoordinate2D?) -> Void) {
        CLGeocoder().geocodeAddressString(searchString, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!.localizedDescription)
                findCompletion(nil)
                return
            }
            
            if placemarks == nil || placemarks!.count == 0 {
                findCompletion(nil)
                return
            }
            
            guard let coordinate = placemarks![0].location?.coordinate else {
                findCompletion(nil)
                return
            }
            
            print("Coordinate: \(coordinate.latitude), \(coordinate.longitude)")
            findCompletion(coordinate)
        })
    }
    
}

// MARK: handle MapView
extension PostPinController: MKMapViewDelegate {
    // Create annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinReuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseID)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

// MARK: handle text fields

// MARK: handle keyboard notifications
extension PostPinController : UITextFieldDelegate {
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
