//
//  ViewController.swift
//  Find Nearby Burrito
//
//  Created by Pan Lin on 6/27/18.
//  Copyright © 2018 Pan Lin. All rights reserved.
//

import UIKit
import MapKit

final class LactionAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init (coordinate:CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title = title
        
        super.init()
    }
}

class LocationVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapAddressLabel: UILabel!
    var locationManager = CLLocationManager()
    var currentLat: Double?
    var currentLng: Double?
    var destLat: Double?
    var destLng: Double?
    var address: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        
        destLocation()
        mapAddressLabel.text = address
        self.navigationController?.navigationBar.topItem?.title = "\(name!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func destLocation() {
        let currentCoordinates = locationManager.location?.coordinate
        let destCoordinates = CLLocationCoordinate2DMake(destLat!, destLng!)
        
        let currentPlacemark = MKPlacemark(coordinate: currentCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let currentItem = MKMapItem(placemark: currentPlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = currentItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else {
                if error != nil {
                    print("Something went wrong")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
        })
        
        let destAnnotation = LactionAnnotation(coordinate: destCoordinates, title: name)
        mapView.addAnnotation(destAnnotation)
        
    }
    
    //route color
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    //annotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
    
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custommannotation")
        annotationView.image = UIImage(named: "Pin")
        annotationView.canShowCallout = true
        
        return annotationView
    }
}

