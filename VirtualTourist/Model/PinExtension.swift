//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 25/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    var coordinate: CLLocationCoordinate2D {
        
        //setter
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        //getter
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    
    
    func compare(to coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longitude == coordinate.longitude)
    }
}

