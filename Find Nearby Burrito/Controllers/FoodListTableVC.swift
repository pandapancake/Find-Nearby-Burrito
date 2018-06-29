//
//  FoodListTableVC.swift
//  Find Nearby Burrito
//
//  Created by Pan Lin on 6/27/18.
//  Copyright © 2018 Pan Lin. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import ObjectMapper
import SwiftyJSON

class FoodListTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var foodListTableView: UITableView!
    var restaurants: [RestaurantsList] = []
    var locationManager = CLLocationManager()
    var currentLat: Double?
    var currentLng: Double?
    var destLat: Double?
    var destLng: Double?
    var address: String?
    var name: String?
    
    override func viewDidLoad() {
        foodListTableView.dataSource = self
        foodListTableView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func defaultLoad() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case.authorizedAlways, .authorizedWhenInUse:
                print("Authorized.")
                let latitude = locationManager.location?.coordinate.latitude
                let longitude = locationManager.location?.coordinate.longitude

                self.currentLat = latitude
                self.currentLng = longitude
                
                findRestaurantLocation()
                
            case .notDetermined, .restricted, .denied:
                print("Error: Either Not Determined, Restricted, or Denied.")
                print(CLLocationManager.authorizationStatus().rawValue)
                break
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            defaultLoad()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            defaultLoad()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    func findRestaurantLocation() {
        LocationService.sharedInstance.currentLat = currentLat
        LocationService.sharedInstance.currentLng = currentLng
        LocationService.sharedInstance.getLocation { (responseString, restaurants) in
            if (responseString == "error"){/* popup here alerting user about error*/ }
            else {
                self.restaurants = restaurants
                self.foodListTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodListTVC
        cell.nameLabel.text = restaurants[indexPath.row].name ?? ""
        cell.addressLabel.text = restaurants[indexPath.row].address ?? ""
        
        if (restaurants[indexPath.row].rating) ?? 0 > 0 {
            cell.ratingLabel.text = "Rating: \(restaurants[indexPath.row].rating!)"
        } else {
            cell.ratingLabel.text = "Rating: No rating available"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        destLat = restaurants[indexPath.row].latitude!
        destLng = restaurants[indexPath.row].longitude!
        address = restaurants[indexPath.row].address!
        name = restaurants[indexPath.row].name!
        
        performSegue(withIdentifier: "goToMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToMap"){
            
            let vc = segue.destination as? LocationVC
            vc?.destLat = destLat!
            vc?.destLng = destLng!
            vc?.address = address!
            vc?.name = name!
        }
    }
}
