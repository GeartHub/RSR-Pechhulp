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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        callNowView.alpha = 0
    }
    @IBAction func cancelButton(_ sender: Any) {
        callNowView.alpha = 0
        locationView.alpha = 1
        callNowButton.alpha = 1
    }
    
    @IBAction func callNowButton(_ sender: Any) {
        locationView.alpha = 0
        callNowButton.alpha = 0
        callNowView.alpha = 1
    }
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
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        let region = MKCoordinateRegionMakeWithDistance(coordinate, (coordinate.latitude * zoomLevel), (coordinate.longitude * zoomLevel))
        mapView.setRegion(region, animated: true)
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = true
        annotationView.image = UIImage(named: "marker")
        return annotationView
    }
}


extension MapViewController: CLLocationManagerDelegate{
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
