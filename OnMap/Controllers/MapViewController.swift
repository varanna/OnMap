//
//  MapViewController.swift
//  OnMap
//
//  Created by Varosyan, Anna on 02.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Constants
    let pinReuseID = "Pin"
    
    //MARK: Properties
    let spinner = ProgressSpinner()
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    //MARK: View overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (ParseClient.shared.needsRefresh) {
            refresh(self)
        }
        displayAllStudents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    // MARK: IBActions
    @IBAction func refresh(_ sender: Any) {
        showRefreshState(true)
        //get the student list and show on map
        ParseClient.shared.getStudentsList{ (successful, error) in
            DispatchQueue.main.async {
                self.showRefreshState(false)
                if successful {
                    self.displayAllStudents()
                } else {
                    Utils.showErrorAlert(self, error)
                }
            }
        }
    }
  
    @IBAction func logout(_ sender: Any) {
        ParseClient.shared.needsRefresh = true
        spinner.show(self)
        LoginClient.shared.logout(completion: {(successful, displayError) in
            DispatchQueue.main.async {
                self.spinner.hide()
                if (successful) {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    Utils.showErrorAlert(self, displayError)
                }
            }
        })
    }
    
    
    //MARK: Private functions
    private func showRefreshState(_ refresh: Bool) {
        refreshButton.isEnabled = !refresh
        if (refresh) {
            spinner.show(self)
        } else {
            spinner.hide()
        }
    }
    
    private func displayAllStudents() {
        //remove old annotations from the map
        let oldAnnotations = mapView.annotations
        mapView.removeAnnotations(oldAnnotations)
        //add annotations to map
        mapView.addAnnotations(createMapAnnotationsForAllStudents())
    }

    // Create map annotations based on student list
    private func createMapAnnotationsForAllStudents() -> [MKPointAnnotation] {
       //create new annotations collection
        var annotations = [MKPointAnnotation]()
        let lstStudent = StudentList.instance.getAll()
        
        for student in lstStudent {
            annotations.append(createAnnotation(student))
        }
        return annotations
    }

    //Create map annotation for a <student>
    private func createAnnotation(_ student: StudentInformation) -> MKPointAnnotation {
        let lat = CLLocationDegrees(student.latitude)
        let long = CLLocationDegrees(student.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL
        return annotation
    }
    
    //MARK: MKMapViewDelegate implementation
    // Create annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: pinReuseID) as? MKPinAnnotationView
        
        if pinAnnotation != nil {
            pinAnnotation!.annotation = annotation
        }
        else {
            pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseID)
            pinAnnotation!.canShowCallout = true
            pinAnnotation!.pinTintColor = .red
            pinAnnotation!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return pinAnnotation
    }
    
    
    //Open browser to annotation link when user taps annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let mediaUrl = view.annotation?.subtitle! {
                UIApplication.shared.open(URL(string: mediaUrl)!, options: [:], completionHandler: nil)
            }
        }
    }
}
