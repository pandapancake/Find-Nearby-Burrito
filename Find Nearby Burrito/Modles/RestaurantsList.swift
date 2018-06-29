//
//  FoodList.swift
//  Find Nearby Burrito
//
//  Created by Pan Lin on 6/28/18.
//  Copyright © 2018 Pan Lin. All rights reserved.
//

import Foundation
import ObjectMapper

class RestaurantsList: Mappable {
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var rating: Double?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        name            <- map["name"]
        latitude        <- map["geometry.location.lat"]
        longitude       <- map["geometry.location.lng"]
        address         <- map["vicinity"]
        rating          <- map["rating"]
        
    }
}
