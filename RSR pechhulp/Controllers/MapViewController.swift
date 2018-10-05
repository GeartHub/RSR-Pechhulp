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
    let zoomLevel: Double = 30 // Optimal zoom level for the map
    let telephoneNumber = "TEL://+319007788990" // Phone number of the RSR service
    var blackSquare: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        configureServices()
        
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
        let url: NSURL = URL(string: telephoneNumber)! as NSURL
        UIApplication.shared.open((url as URL), options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    /**
     Shows and checks the required user premissions
    */
    func configureServices(){
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
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Zooms to the users location
     
     - Parameter coordinate: The users coordinations
     */
    func zoomToCurrentLocation(with coordinates: CLLocationCoordinate2D){
        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: (coordinates.latitude * zoomLevel), longitudinalMeters: (coordinates.longitude * zoomLevel))
        UIView.animate(withDuration: 1.0, animations: {self.mapView.setRegion(region, animated: true)}) { (value: Bool) in
            self.showUserLocation(with: coordinates)


        }
    }
    /**
     Fills the labels with this address information of the user
     
     - Parameter coordinate: The users coordinations
     */
    func showUserLocation(with coordinates: CLLocationCoordinate2D){
        
        locationView.alpha = 1
        
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                self.userLocationLabel.text = String(placemark.thoroughfare! + " " + placemark.subThoroughfare! + ", \n " + placemark.postalCode! + ", " +  placemark.locality!)
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        if currentCoordinates == nil{
            zoomToCurrentLocation(with: latestLocation.coordinate)
        }
        currentCoordinates = latestLocation.coordinate
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.image = UIImage(named: "marker")
        locationView.frame = CGRect(x: -(locationView.frame.width  / 2), y: -(locationView.frame.height), width: locationView.frame.width, height: locationView.frame.height)
        annotationView.addSubview(locationView)
        
        return annotationView
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
