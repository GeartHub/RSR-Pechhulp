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
    let zoomLevel: Double = 30
    let number = "TEL://+319007788990"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        callNowView.isHidden = true
        callNowView.alpha = 0
        locationView.alpha = 0
    }
    @IBAction func callNowButton(_ sender: Any) {
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
    
    //hide the address information and button
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
        } else if status == .denied || status == .restricted{
            let alert = UIAlertController(title: "GPS aanzetten", message: "U heeft deze app geen toegang gegeven voor GPS. Zet dit a.u.b aan in uw instellingen.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    //Zooms to the location of the user on the load of the VC
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        //Sets the zoom region
        let region = MKCoordinateRegionMakeWithDistance(coordinate, (coordinate.latitude * zoomLevel), (coordinate.longitude * zoomLevel))
        mapView.setRegion(region, animated: true)
        
        locationView.alpha = 1
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
