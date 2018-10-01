//
//  MapViewController.swift
//  RSR pechhulp
//
//  Created by Geart Otten on 14/09/2018.
//  Copyright © 2018 Geart Otten. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var callNowButton: UIButton!
    @IBOutlet weak var callNowView: UIView!
    let locationManager: CLLocationManager = CLLocationManager()
    var currentCoordinates: CLLocationCoordinate2D?
    var pinAnnotationView: MKPinAnnotationView!
    let geoCoder = CLGeocoder()
    let zoomLevel: Double = 30 // waarom 30
    let number = "TEL://+319007788990"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        configureLocationServices()
        
        //MARK: View Setup
        callNowView.isHidden = true
        callNowView.alpha = 0
        locationView.alpha = 0
    }
    
    @IBAction func callNowButton(_ sender: Any) {
        
        //MARK: Show call now pop-up
        self.callNowView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.locationView.alpha = 0
            self.callNowButton.alpha = 0
            self.callNowView.alpha = 1
        }, completion: {
            (value: Bool) in
            self.locationView.isHidden = true
            self.callNowButton.isHidden = true
            
        })
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        //MARK: Hide call now pop-up
        self.locationView.isHidden = false
        self.callNowButton.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.locationView.alpha = 1
            self.callNowButton.alpha = 1
            self.callNowView.alpha = 0
        }, completion: {
            (value: Bool) in
            self.callNowView.isHidden = true
            
        })
    }
    
    @IBAction func callPopUp(_ sender: Any) {
        let url: NSURL = URL(string: "TEL://+319007788990")! as NSURL
        UIApplication.shared.open((url as URL), options: [:], completionHandler: nil)
    }
    
    func configureLocationServices(){
        locationManager.delegate = self
        mapView.delegate = self
        
        if !Reachability.isConnectedToNetwork(){
            showError(error: .noInternetConnectionFound)
        }
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showError(error: .noGPSConnectionFound)
        default:
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    /**
     Shows an error to the user when they didn't meet the requirements needed to load the application.
     
     - Parameter error: The error situation of the user. e.g No internet.
     */
    func showError(error: ErrorSituation){
        let errorMessages = ErrorMessages()
        
        let alert: UIAlertController = UIAlertController(title: errorMessages[error].title, message: errorMessages[error].message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Zooms to the users location
     
     - Parameter coordinate: The users coordinations
     */
    func zoomToLatestLocation(with coordinates: CLLocationCoordinate2D){
        let region = MKCoordinateRegionMakeWithDistance(coordinates, (coordinates.latitude * zoomLevel), (coordinates.longitude * zoomLevel))
        mapView.setRegion(region, animated: true)
        showUsersLocation(with: coordinates)
    }
    /**
     Zooms to the users location
     
     - Parameter coordinate: The users coordinations
     */
    func showUsersLocation(with coordinates: CLLocationCoordinate2D){
        
        locationView.alpha = 1
        
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                
                var addressInformationString: String = ""
                self.fillPlacemark(pm: placemark)
                
//                if placemark.thoroughfare != nil {
//                    addressInformationString = addressInformationString + placemark.thoroughfare! + " "
//                }
//                if placemark.subThoroughfare != nil {
//                    addressInformationString = addressInformationString + placemark.subThoroughfare! + ", \n"
//                }
//                if placemark.postalCode != nil {
//                    addressInformationString = addressInformationString + placemark.postalCode! + ", "
//                }
//                if placemark.locality != nil {
//                    addressInformationString = addressInformationString + placemark.locality! + ""
//                }
                self.userLocationLabel.text = addressInformationString
            }
        }
    }
    
    func fillPlacemark(pm: CLPlacemark){
        let placemarkMirror = Mirror(reflecting: pm)
        print(pm)
        print(placemarkMirror)
        for (index, attr) in placemarkMirror.children.enumerated(){
            print(attr, index)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        if currentCoordinates == nil{
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        currentCoordinates = latestLocation.coordinate
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.image = UIImage(named: "marker")
        return annotationView
    }
}
