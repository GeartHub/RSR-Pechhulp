//
//  ViewController.swift
//  RSR pechhulp
//
//  Created by Geart Otten on 14/09/2018.
//  Copyright © 2018 Geart Otten. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    // Decleration of all Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var callNowButton: UIButton!
    @IBOutlet weak var callNowView: UIView!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    var pinAnnotationView: MKPinAnnotationView!
    let geoCoder = CLGeocoder()
    let zoomLevel: Double = 40
    let number = "TEL://+319007788990"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        callNowView.isHidden = true
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        callNowView.isHidden = false
        locationView.isHidden = true
        callNowButton.isHidden = true
    }
    
    //hide the address information and button
    @IBAction func callNowButton(_ sender: Any) {
        locationView.isHidden = true
        callNowButton.isHidden = true
        callNowView.isHidden = false
    }
    @IBAction func callPopUp(_ sender: Any) {
        let url: NSURL = URL(string: "TEL://+319007788990")! as NSURL
        UIApplication.shared.open((url as URL), options: [:], completionHandler: nil)
    }
    
    //Configure the services for finding the location of the user
    func configureLocationServices(){
        locationManager.delegate = self
        mapView.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways{
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    //Zooms to the location of the user on the load of the VC
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        //Sets the zoom region
        let region = MKCoordinateRegionMakeWithDistance(coordinate, (coordinate.latitude * zoomLevel), (coordinate.longitude * zoomLevel))
        mapView.setRegion(region, animated: true)
        
        //Finds the location based on the users location and fills the labels on the screen
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                var addressInformationString: String = ""
                
                if placemark.thoroughfare != nil {
                    addressInformationString = addressInformationString + placemark.thoroughfare! + " "
                }
                if placemark.subThoroughfare != nil {
                    addressInformationString = addressInformationString + placemark.subThoroughfare! + ", \n"
                }
                if placemark.postalCode != nil {
                    addressInformationString = addressInformationString + placemark.postalCode! + ", "
                }
                if placemark.locality != nil {
                    addressInformationString = addressInformationString + placemark.locality! + ""
                }
                self.userLocationLabel.text = addressInformationString
            }
        }
    }
    
    //Setting the marker information
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.image = UIImage(named: "marker")
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate{
    //Checks if there was an location update from the user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let latestLocation = locations.first else { return }
        
        if currentCoordinate == nil{
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        currentCoordinate = latestLocation.coordinate
    }
}

extension MapViewController: MKMapViewDelegate{

}
