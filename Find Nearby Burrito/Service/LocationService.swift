//
//  LocationService.swift
//  Find Nearby Burrito
//
//  Created by Pan Lin on 6/27/18.
//  Copyright © 2018 Pan Lin. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftyJSON

class LocationService: NSObject {
    static let sharedInstance = LocationService()
    var currentLat: Double?
    var currentLng: Double?
    
    func getLocation(completion:@escaping(String, [RestaurantsList]) -> Void)  {
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(currentLat!),\(currentLng!)&radius=1500&type=restaurant&keyword=burrito&key=AIzaSyCQO2o0JW7FG5Eas358wNJrhU7s7ZUxvAo"
        
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                var restaurants: [RestaurantsList] = []
                
                guard response.result.isSuccess,
                    let jsonData = response.result.value else {
                        print("Get Location Unsuccessful")
                        print("Error while fetching data: \(String(describing: response.result.error))")
                        completion("failure", restaurants)
                        return
                }
                
                let jsonArray = JSON(jsonData)
                let resultJson = jsonArray["results"]
                
                for json in resultJson {
                    let list = RestaurantsList(JSONString: json.1.rawString()!)
                    restaurants.append(list!)
                    print(list)
                }
               
                
                
                print("JSON:\(restaurants)")
                
                completion("success", restaurants)
                print("Get Location Successful")
                
            case .failure(let error):
                print("Get Location Unsuccessful")
                print(error)
            }
        }
    }
}

